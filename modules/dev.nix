{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		cargo
		cargo-espflash
		cargo-generate
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
		rustc
		rustfmt
		rust-analyzer
		xh
		zig
	];
}

# vim: ts=4
