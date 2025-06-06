{ config, pkgs, ...}:

{
	services = {
		locate = {
			enable = true;
			package = pkgs.plocate;
			#localuser = null;
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

	security = {
		sudo-rs.enable = true;
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

		gnupg.agent = {
			enable = true;
			enableSSHSupport = true;
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
		dool
		ecryptfs
		file
		gparted
		gnupg
		killall
		kopia
		lm_sensors
		neovim
		nix-index
		openssl
		page
		pciutils
		rclone
		rename
		systemctl-tui
		unzip
		usbutils
		uutils-coreutils-noprefix
		#vimPlugins.codeium-vim
		vimPlugins.windsurf-vim
		wget
		xclip
		xq-xml
		zip
	];
}

# vim: ts=4
