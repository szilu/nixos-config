{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		cargo
		cargo-espflash
		cargo-generate
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
		nodejs_22
		python3Minimal
		xh
		zig
	];
}

# vim: ts=4
