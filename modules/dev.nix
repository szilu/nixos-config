{ config, pkgs, ...}:

{
	environment.systemPackages = with pkgs; [
		deno
		gcc
		git
		gnumake
		go
		hugo
		jq
		nodejs_22
		python3Minimal
		zig
	];
}

# vim: ts=4
