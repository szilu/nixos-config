{ config, pkgs, ...}:

{
	services = {
		locate = {
			enable = true;
			package = pkgs.mlocate;
			localuser = null;
		};

		openssh = {
			enable = true;
			settings.X11Forwarding = true;
		};

		logrotate.enable = true;
	};

	programs = {
		nix-ld.enable = true;
		ecryptfs.enable = true;

		neovim = {
			enable = true;
			defaultEditor = true;
			viAlias = true;
			vimAlias = true;
		};
	};

	virtualisation.docker = {
		enable = true;
		storageDriver = "btrfs";
	};

	environment.systemPackages = with pkgs; [
		borgbackup
		cachix
		compsize
		dash
		dig
		docker
		ecryptfs
		file
		gcc
		git
		gparted
		killall
		lm_sensors
		neovim
		nix-index
		openssl
		pciutils
		unzip
		usbutils
		vimPlugins.codeium-vim
		wget
	];
}

# vim: ts=4