{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		android-tools
		deno
		dive
		espup
		espflash
		gcc
		git
		gnumake
		go
		hugo
		jujutsu
		jq
		ldproxy
		nodejs
		python3Minimal
		rustup
		xh
		zig
	];
}

# vim: ts=4
