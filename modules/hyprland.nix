{ config, lib, pkgs, ...}:

let
	# Hyprland comes from nixpkgs (pkgs.hyprland, currently 0.55.3, cached).
	#
	# The hy3 plugin is the awkward part: upstream has only ever tagged hl0.55.0
	# (built for Hyprland 0.55.0), and nixpkgs ships that hy3-0.55.0 even though
	# its hyprland is 0.55.3. hy3 guards loading with an EXACT Hyprland-commit
	# check (COMPOSITOR_HASH != CLIENT_HASH -> "target hyprland version
	# mismatch"), so the 0.55.0 plugin refuses to load on the 0.55.3 compositor.
	# No published hy3 matches 0.55.3 anywhere, so there is no clean matched pair
	# to pin (flake or nixpkgs).
	#
	# hy3 compiles fine against the 0.55.3 headers (the plugin API is compatible
	# across these patch releases) — only the commit guard rejects it. So build
	# hy3 with HY3_NO_VERSION_CHECK defined (an `#ifndef` around the check in
	# src/main.cpp) to drop the guard. Tiny source build of hy3 only; hyprland
	# stays cached. Revisit / remove this override once upstream hy3 tags a
	# release for the 0.55.x Hyprland we run.
	hy3 = pkgs.hyprlandPlugins.hy3.overrideAttrs (prev: {
		preConfigure = (prev.preConfigure or "") + ''
			export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DHY3_NO_VERSION_CHECK"
		'';
	});
	# Brave keeps its passwords in the gnome-keyring wallet
	# (--password-store=gnome-libsecret). Nothing unlocks that wallet under
	# autologin, so do it here: prompt, unlock, verify. If it is still locked
	# afterwards Brave is NOT started — otherwise it would silently fall back to
	# storing passwords in plaintext (--password-store=basic).
	# Check the lock probe by hand with:
	#   busctl --user get-property org.freedesktop.secrets \
	#     /org/freedesktop/secrets/collection/login \
	#     org.freedesktop.Secret.Collection Locked
	brave-unlock = pkgs.writeShellScriptBin "brave-unlock" ''
		locked() {
			[ "$(busctl --user get-property org.freedesktop.secrets \
				/org/freedesktop/secrets/collection/login \
				org.freedesktop.Secret.Collection Locked 2>/dev/null)" != "b false" ]
		}

		if locked; then
			pw=$(wofi --dmenu --password --prompt "Unlock wallet") || exit 1
			# The daemon is D-Bus activated, so it has no control socket
			# ($XDG_RUNTIME_DIR/keyring is absent) and a plain --unlock just forks a
			# second daemon that owns nothing. --replace takes over the Secret
			# Service name and unlocks the login keyring with the stdin password.
			printf '%s' "$pw" | gnome-keyring-daemon \
				--replace --daemonize --unlock --components=secrets >/dev/null 2>&1
		fi

		if locked; then
			notify-send -u critical "Wallet locked" "Brave not started."
			exit 1
		fi

		exec brave --password-store=gnome-libsecret "$@"
	'';
in
{
	services.libinput.enable = true;

	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
	};

	i18n.inputMethod = {
		enable = true;
		type = "fcitx5";
		fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ];
	};

	# Autologin straight into Hyprland, no greeter. The user is per-host, set in
	# configuration-<host>.nix as services.greetd.settings.initial_session.user.
	# gnome-keyring is enabled in modules/apps.nix and its daemon is started by
	# PAM here, but autologin gives PAM no password, so the wallet stays locked
	# until brave-unlock (below) opens it.
	services.greetd = {
		enable = true;
		settings = rec {
			initial_session = {
				command = "${config.programs.hyprland.package}/bin/start-hyprland";
			};
			default_session = initial_session;
		};
	};

	programs.thunar = {
		enable = true;
		plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];
	};

	programs.sway.enable = true;
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		# package / portalPackage left at their defaults: pkgs.hyprland and
		# pkgs.xdg-desktop-portal-hyprland from nixos-26.05.
	};

	environment.systemPackages = with pkgs; [
		blueman
		brave-unlock
		brightnessctl
		dmenu
		dunst
		flameshot
		grim
		hyprpaper
		hy3
		libnotify
		networkmanager_dmenu
		pamixer
		polkit_gnome
		rose-pine-hyprcursor
		slurp
		swaybg
		swayidle
		swaylock
		swaynotificationcenter
		waybar
		wl-clipboard
		wlogout
		wlr-randr
		wofi
		wtype
	];
}

# vim: ts=4
