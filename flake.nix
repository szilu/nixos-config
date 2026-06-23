{
	description = "NixOS configuration";

	inputs = {
		#nixpkgs.url = "nixpkgs/nixos-25.05";
		#nixpkgs.url = "nixpkgs/nixos-25.11";
		nixpkgs.url = "nixpkgs/nixos-26.05";

		# Hyprland and the hy3 plugin come from nixpkgs (pkgs.hyprland and
		# pkgs.hyprlandPlugins.hy3). nixpkgs builds the plugin against the same
		# hyprland in the tree, so they are always a matched pair and both are
		# prebuilt on cache.nixos.org. The single nixos-26.05 pin keeps them in
		# sync; bumping it advances both together. (Dedicated hyprwm/hy3 flake
		# inputs were dropped — they dragged in a second nixpkgs and forced
		# from-source builds for no benefit.)
	};

	outputs = { self, nixpkgs, ... }:
		let
			system = "x86_64-linux";
		in {
			nixosConfigurations.fanny = nixpkgs.lib.nixosSystem {
				inherit system;
				modules = [ ./configuration-fanny.nix ];
			};
			nixosConfigurations.harmony = nixpkgs.lib.nixosSystem {
				inherit system;
				modules = [ ./configuration-harmony.nix ];
			};
		};
}

#{
#	description = "NixOS configuration";
#
#	inputs = {
#		nixpkgs.url = "nixpkgs/nixos-24.11";
#		nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
#	};
#
#	outputs = { self, nixpkgs, nixpkgs-unstable }:
#		let
#			system = "x86_64-linux";
#			overlay-unstable = final: prev: {
#				#unstable = nixpkgs-unstable.legacyPackages.${prev.system};
#				unstable = import nixpkgs-unstable {
#					 inherit system;
#					 config.allowUnfree = true;
#				};
#
#			};
#		in {
#			nixosConfigurations.fanny = nixpkgs.lib.nixosSystem {
#				inherit system;
#				modules = [
#					({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
#					./configuration-fanny.nix
#				];
#			};
#			nixosConfigurations.harmony = nixpkgs.lib.nixosSystem {
#				inherit system;
#				modules = [
#					({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable]; })
#					./configuration-harmony.nix
#				];
#			};
#		};
#}

# vim: ts=4
