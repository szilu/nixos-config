{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		android-tools
		cargo
		cargo-bloat
		cargo-bump
		cargo-cache
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
		gnumake
		go
		hugo
		jujutsu
		jq
		ldproxy
		mold
		nodejs
		pandoc
		pnpm
		poppler-utils
		python3Minimal
		rustc
		sccache
		wkhtmltopdf
		xh
		xxd
		zig
	];
}

# vim: ts=4
