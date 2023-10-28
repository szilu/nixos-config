{
	description = "NixOS configuration";

	inputs = {
		#nixpkgs.url = "nixpkgs/nixos-23.11";
		nixpkgs.url = "nixpkgs/unstable";
		nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
	};

	outputs = { self, nixpkgs, nixpkgs-unstable }:
		let
			system = "x86_64-linux";
			overlay-unstable = final: prev: {
				#unstable = nixpkgs-unstable.legacyPackages.${prev.system};
				unstable = import nixpkgs-unstable {
					 inherit system;
					 config.allowUnfree = true;
				};

			};
		in {
			nixosConfigurations."<hostname>" = nixpkgs.lib.nixosSystem {
				inherit system;
				modules = [
					({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
					./configuration.nix
				];
			};
		};
}

#vim: ts=4
