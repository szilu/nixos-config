{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		android-tools
		cargo
		cargo-bloat
		cargo-bump
		cargo-cache
		cargo-cyclonedx
		cargo-deny
		cargo-edit
		cargo-features-manager
		cargo-flamegraph
		cargo-llvm-cov
		cargo-lock
		cargo-outdated
		cargo-profiler
		cargo-seek
		cargo-sweep
		cargo-udeps
		cargo-ui
		cargo-update
		cargo-vet
		cargo-watch
		clang
		clippy
		cosign
		cyclonedx-cli
		deno
		dive
		espup
		espflash
		gcc
		gdb
		gh
		git
		glow
		gnumake
		go
		hugo
		jujutsu
		jq
		ldproxy
		mold
		nodejs
		openssl.dev
		pandoc
		pkg-config
		pnpm
		poppler-utils
		python3Minimal
		rustc
		rustfmt
		sccache
		semgrep
		syft
		wkhtmltopdf
		xh
		xxd
		zig
	];
	environment.variables.PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
}

# vim: ts=4
