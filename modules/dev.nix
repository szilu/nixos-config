{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		#cargo
		cargo-bloat
		cargo-crev
		cargo-geiger
		cargo-espflash
		cargo-generate
		cargo-outdated
		cargo-vet
		cargo-watch
		clippy
		deno
		espup
		espflash
		gcc
		git
		gnumake
		go
		hugo
		jq
		ldproxy
		nodejs
		python3Minimal
		#rustc
		#rustfmt
		rustup
		#rust-analyzer
		xh
		zig
	];
}

# vim: ts=4
