#!/usr/bin/env bash
#
# why.sh — explain what a Nix build will compile from source, and why it is not
# served from a binary cache.
#
# Two modes, auto-detected from the first argument:
#
#   SYSTEM MODE  (arg is a host in nixosConfigurations, or omitted)
#     ./why.sh                 # system toplevel for $(hostname)
#     ./why.sh harmony         # system toplevel for harmony
#
#   PACKAGE MODE (arg is anything else -> a package attr under <host>.pkgs)
#     ./why.sh audacity        # investigate pkgs.audacity (host = $(hostname))
#     ./why.sh audacity harmony
#     ./why.sh hyprlandPlugins.hy3 fanny
#
# For the chosen target it resolves the derivation, asks Nix what it would BUILD
# (vs substitute), and for each build prints pname/version/platform, whether the
# cache has the output (MISSING = Hydra never built this exact drv; HAS = cached
# yet building => substituter/config problem), and the dependency chain.
#
# In PACKAGE mode it ends with a verdict locating the divergence: is the package
# itself the only uncached node (all inputs cached -> Hydra built a *different*
# derivation, e.g. a newer rev), or is some dependency the real culprit?
#
# Nothing here builds or activates anything; it only inspects derivations.
#
# Env:
#   FLAKE=<dir>     flake directory (default: this script's directory)
#   CACHE_URL=<url> binary cache to check (default: https://cache.nixos.org)
#   WHY_ALL=1       in system mode, also list the NixOS unit/config generators
#                   (normally omitted: they are host-specific and never cached)
#   WHY_DIFF=1|0    in package mode, nix-diff our derivation against the same
#                   package built from the channel-tested nixpkgs rev to explain
#                   why our output hash diverges from Hydra's (default: on)
#   REF=<rev|ref>   reference to diff against: a bare nixpkgs rev/branch, or a
#                   full flakeref. Default: the channel-tested rev of the channel
#                   this flake tracks (from channels.nixos.org/<chan>/git-revision)
#
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
FLAKE="${FLAKE:-$SCRIPT_DIR}"
CACHE="${CACHE_URL:-https://cache.nixos.org}"
SYSTEM=$(nix eval --raw --impure --expr 'builtins.currentSystem' 2>/dev/null || echo x86_64-linux)

# --- discover hosts and decide mode -----------------------------------------
HOSTS=$(nix eval --json "${FLAKE}#nixosConfigurations" --apply builtins.attrNames 2>/dev/null \
	| tr -d '[]"' | tr ',' ' ' || true)
is_host() { printf '%s\n' $HOSTS | grep -qx -- "$1"; }
first_host() { printf '%s\n' $HOSTS | head -1; }

ARG1="${1:-}"
ARG2="${2:-}"
if [ -z "$ARG1" ]; then
	MODE=system; HOST=$(hostname)
elif is_host "$ARG1"; then
	MODE=system; HOST="$ARG1"
else
	MODE=pkg; PKG="$ARG1"; HOST="${ARG2:-$(hostname)}"
fi
# Package attrs must be evaluated in *some* host's pkgs; fall back if needed.
if ! is_host "$HOST"; then HOST=$(first_host); fi

if [ "$MODE" = system ]; then
	ATTR="${FLAKE}#nixosConfigurations.${HOST}.config.system.build.toplevel"
	LABEL="system toplevel  (host: $HOST)"
else
	ATTR="${FLAKE}#nixosConfigurations.${HOST}.pkgs.${PKG}"
	LABEL="package: $PKG  (pkgs of: $HOST)"
fi

echo "target: $LABEL"
echo "flake:  $FLAKE"
echo "cache:  $CACHE"
echo

# --- resolve the derivation and its output (no build) ------------------------
if ! TOP=$(nix eval --raw "${ATTR}.drvPath" 2>/tmp/why.eval.$$); then
	echo "error: could not evaluate ${ATTR}" >&2
	sed 's/^/  /' /tmp/why.eval.$$ >&2 || true
	rm -f /tmp/why.eval.$$; exit 1
fi
rm -f /tmp/why.eval.$$
OUT=$(nix eval --raw "$ATTR" 2>/dev/null || true)
echo "drv: $TOP"
[ -n "$OUT" ] && echo "out: $OUT"
if [ -n "$OUT" ]; then
	if nix path-info --store "$CACHE" "$OUT" >/dev/null 2>&1; then
		echo "out on $CACHE: YES"
	else
		echo "out on $CACHE: NO"
	fi
fi
echo

# --- what would be built to realise the target? ------------------------------
echo "== build-vs-fetch plan (dry run) =="
DRY=$(nix-store --realise --dry-run "$TOP" 2>&1 || true)
BUILD_DRVS=$(printf '%s\n' "$DRY" \
	| awk '/will be built/{f=1;next} /will be fetched|will be copied|don.t (know|need)/{f=0} f' \
	| tr -d '[:blank:]' | grep '\.drv$' | sort -u || true)

if [ -z "$BUILD_DRVS" ]; then
	echo
	echo "Nothing will be built — the whole closure is substitutable from the cache."
	exit 0
fi

# Classify NixOS eval-time generators (always local, never cached) so system
# mode isn't drowned in unit/config noise. Match on the name (hash stripped).
CFG_RE='(^unit-|\.(service|socket|target|timer|mount|slice|conf|toml|ini|json|desktop)$|-(service|socket)-disabled$|^(etc|etc-.*|system-path|system-units|user-units|system-generators|user-generators|initrd-.*|initrd-units|boot\.json|activate|set-environment|hwdb\.bin|system-shutdown|dbus-1|udev-rules|udev-path|desktops|wireplumber-.*|X-Restart-Triggers.*|security-wrapper-.*|nixos-system-.*|etc-pam-environment|etc-profile))$'

drvname() { local b; b=$(basename "$1" .drv); printf '%s\n' "${b#*-}"; }

PKG_DRVS=""; CFG_COUNT=0
while IFS= read -r d; do
	[ -n "$d" ] || continue
	if [ "$MODE" = system ] && [ "${WHY_ALL:-0}" != 1 ] && printf '%s' "$(drvname "$d")" | grep -qE "$CFG_RE"; then
		CFG_COUNT=$((CFG_COUNT + 1))
	else
		PKG_DRVS+="$d"$'\n'
	fi
done <<< "$BUILD_DRVS"
PKG_DRVS=$(printf '%s' "$PKG_DRVS" | grep -v '^$' || true)

NPKG=$(printf '%s\n' "$PKG_DRVS" | grep -c . || true)
echo
echo "== $NPKG package derivation(s) to build =="
[ "$CFG_COUNT" -gt 0 ] && echo "   (+ $CFG_COUNT NixOS unit/config generators omitted — always built locally; WHY_ALL=1 to show)"
echo

cached_but_built=0; only_target=1
while IFS= read -r drv; do
	[ -n "$drv" ] || continue
	[ "$drv" != "$TOP" ] && only_target=0
	echo "▶ $(drvname "$drv")"
	echo "    drv: $drv"
	nix derivation show "$drv" 2>/dev/null \
		| grep -oE '"(pname|version|system)":"[^"]*"|"blas64":"[^"]*"|BINARY:STRING=[0-9]+|INTERFACE64:BOOL=[A-Z]+' \
		| sed 's/^/    /' | sort -u | head -10 || true
	for o in $(nix-store -q --outputs "$drv" 2>/dev/null || true); do
		if nix path-info --store "$CACHE" "$o" >/dev/null 2>&1; then
			echo "    cache: HAS     $o   <-- cached yet building: substituter/config issue"
			cached_but_built=$((cached_but_built + 1))
		else
			echo "    cache: MISSING $o"
		fi
	done
	if [ "$drv" = "$TOP" ]; then
		echo "    (this is the target itself)"
	else
		echo "    pulled in by:"
		nix why-depends --derivation "$TOP" "$drv" 2>/dev/null | sed 's/^/      /' | head -20 \
			|| echo "      (why-depends unavailable)"
	fi
	echo
done <<< "$PKG_DRVS"

# --- divergence diff: why does OUR derivation differ from the cached one? -------
# In package mode, when the target is uncached, the useful question is not "what
# builds" but "why does my drv hash differ from the one Hydra built and cached".
# Build the *reference* derivation for the same package from the channel-tested
# nixpkgs rev (the rev whose binaries Hydra has actually populated on the cache)
# and nix-diff it against our locally-evaluated drv. The first differing input or
# attr is the reason our output path — the cache key — is not what Hydra signed.
# Disable with WHY_DIFF=0; override the reference with REF=<rev|flakeref>.
if [ "$MODE" = pkg ] && [ "${WHY_DIFF:-1}" = 1 ]; then
	echo "== divergence diff (ours vs channel-tested reference) =="

	REF_IN="${REF:-}"
	REF_FLAKE=""
	if [ -z "$REF_IN" ]; then
		# Which channel does this flake track? (read the locked input's original ref)
		CHAN=$(nix flake metadata "$FLAKE" --json 2>/dev/null \
			| grep -oE '"ref":"(nixos-[^"]*|nixpkgs-unstable|nixos-unstable)"' | head -1 \
			| sed 's/.*:"//; s/"$//' || true)
		# -L: channels.nixos.org/<chan> is a redirect to the dated release dir.
		[ -n "$CHAN" ] && CREV=$(curl -fsSL "https://channels.nixos.org/$CHAN/git-revision" 2>/dev/null || true)
		if [ -n "${CREV:-}" ]; then
			REF_FLAKE="github:NixOS/nixpkgs/$CREV"
			echo "  channel: $CHAN  ->  tested rev $CREV"
		else
			echo "  (diff skipped: no channel-tested rev for '${CHAN:-?}' — channel may not"
			echo "   be published yet. Pass REF=<rev|flakeref> to diff against a known build.)"
		fi
	else
		case "$REF_IN" in
			*:*) REF_FLAKE="$REF_IN" ;;                       # already a flakeref
			*)   REF_FLAKE="github:NixOS/nixpkgs/$REF_IN" ;;  # bare rev/branch
		esac
		echo "  reference: $REF_FLAKE"
	fi

	if [ -n "$REF_FLAKE" ]; then
		REF_PKG_EXPR="(import (builtins.getFlake \"$REF_FLAKE\") { system = \"$SYSTEM\"; config.allowUnfree = true; }).${PKG}"
		if REFDRV=$(nix eval --raw --impure --expr "${REF_PKG_EXPR}.drvPath" 2>/tmp/why.ref.$$); then
			echo "  our drv: $TOP"
			echo "  ref drv: $REFDRV"
			if [ "$REFDRV" = "$TOP" ]; then
				echo
				echo "  Identical drv path: no eval divergence. The cache genuinely lacks this"
				echo "  exact build (true Hydra lag), or your substituters are misconfigured."
			else
				# Confirm the reference output really is on the cache (so we are diffing
				# against what Hydra built, not just another local variant).
				REFOUT=$(nix eval --raw --impure --expr "$REF_PKG_EXPR" 2>/dev/null || true)
				if [ -n "$REFOUT" ]; then
					if nix path-info --store "$CACHE" "$REFOUT" >/dev/null 2>&1; then
						echo "  ref out: $REFOUT  (present on $CACHE — this IS the cached build)"
					else
						echo "  ref out: $REFOUT  (also absent from $CACHE — channel still building?)"
					fi
				fi
				echo
				echo "  --- nix-diff: ours  ->  reference (differences explain the hash) ---"
				if command -v nix-diff >/dev/null 2>&1; then
					nix-diff "$TOP" "$REFDRV" 2>/dev/null | sed 's/^/  /' || true
				else
					nix run nixpkgs#nix-diff -- "$TOP" "$REFDRV" 2>/dev/null | sed 's/^/  /' \
						|| echo "  (need nix-diff:  nix run nixpkgs#nix-diff -- $TOP $REFDRV)"
				fi
			fi
		else
			echo "  (diff skipped: could not evaluate ${PKG} in $REF_FLAKE)"
			sed 's/^/    /' /tmp/why.ref.$$ 2>/dev/null || true
		fi
		rm -f /tmp/why.ref.$$
	fi
	echo
fi

# --- verdict -----------------------------------------------------------------
echo "== verdict =="
if [ "$cached_but_built" -gt 0 ]; then
	echo "  $cached_but_built output(s) ARE on the cache but build anyway —"
	echo "  suspect nix.settings.substituters / trusted-public-keys (clobbered default)."
fi
if [ "$MODE" = pkg ]; then
	if [ "$only_target" = 1 ]; then
		echo "  Only '$PKG' itself is uncached; all its build inputs are cached."
		echo "  => the derivation is deterministic from cached inputs, so if Hydra's"
		echo "     cache lacks THIS output, Hydra built '$PKG' from different inputs"
		echo "     (a newer/older nixpkgs rev) than your flake.lock pins."
		echo "  See the 'divergence diff' section above for the exact differing input/attr"
		echo "  (or set REF=<rev|flakeref> to compare against a specific build). To unblock:"
		echo "     nix copy --to ssh://<host> ${ATTR}   # build elsewhere, push here"
	else
		echo "  '$PKG' is uncached because deeper dependencies are uncached (listed above)."
		echo "  Fix the topmost uncached dependency; '$PKG' then follows from cache."
	fi
else
	echo "  $NPKG real package(s) absent from $CACHE for this rev"
	echo "  (Hydra lag/skip, an insecure/unfree skip, or an eval divergence)."
	echo "  Investigate any one with:  ./why.sh <pkgname> $HOST"
fi
