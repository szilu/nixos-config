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

		logrotate = {
			enable = true;
			settings = {
				header.compress = true;
				syslog = {
					files = ["/var/log/messages" "/var/log/warn"];
					frequency = "weekly";
					rotate = 5;
				};
			};
		};
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
		bc
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
