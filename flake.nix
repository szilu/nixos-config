{
	description = "NixOS configuration";

	inputs = {
		#nixpkgs.url = "nixpkgs/nixos-24.11";
		nixpkgs.url = "nixpkgs/nixos-25.05";
	};

	outputs = { self, nixpkgs }:
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
