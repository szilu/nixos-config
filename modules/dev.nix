{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		android-tools
		cargo
		cargo-bloat
		cargo-bump
		cargo-cache
		cargo-edit
		cargo-features-manager
		cargo-flamegraph
		cargo-llvm-cov
		cargo-lock
		cargo-outdated
		cargo-profiler
		cargo-release
		cargo-seek
		cargo-sweep
		cargo-udeps
		cargo-ui
		cargo-update
		cargo-watch
		clang
		clippy
		deno
		dive
		espup
		espflash
		gcc
		gdb
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
		pkgconfig
		pnpm
		poppler-utils
		python3Minimal
		rustc
		rustfmt
		sccache
		semgrep
		wkhtmltopdf
		xh
		xxd
		zig
	];
	environment.variables.PKG_CONFIG_PATH = "/run/current-system/sw/lib/pkgconfig";
}

# vim: ts=4
