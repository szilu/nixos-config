{ config, pkgs, ...}:

{
	# Quiet boot: `quiet` silences systemd's boot-status text, consoleLogLevel 3
	# keeps kernel printk below KERN_ERR off the console, so late start-up noise
	# (docker bridge setup, TLP, powertop autotune) does not paint over tty1
	# while greetd is starting the session. Nothing is lost — it all still lands
	# in the journal (journalctl -k -b).
	boot = {
		consoleLogLevel = 3;
		kernelParams = [ "quiet" ];
	};

	# Trust wheel users so they can receive store paths pushed from another
	# machine (`nix copy --to ssh://thishost ...`) without those paths needing a
	# binary-cache signature. Lets you build on a fast host and push the closure
	# to a slow one. NOTE: enabling this is itself a rebuild, so the first push to
	# a host that doesn't have it yet must be done as root (root is always
	# trusted); afterwards any wheel user can push.
	nix.settings.trusted-users = [ "root" "@wheel" ];

	services = {
		locate = {
			enable = true;
			package = pkgs.plocate;
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

		ssh.extraConfig = ''
			WarnWeakCrypto no-pq-kex
		'';
	};

	virtualisation.docker = {
		enable = true;
		storageDriver = "btrfs";
	};

	environment.systemPackages = with pkgs; [
		bc
		borgbackup
		brotli
		cachix
		compsize
		dash
		dig
		docker
		dool
		exfatprogs
		gocryptfs
		fd
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
		psmisc
		rclone
		rename
		ripgrep
		systemctl-tui
		unzip
		usbutils
		uutils-coreutils-noprefix
		vimPlugins.windsurf-vim
		wget
		xclip
		xq-xml
		zip
	];
}

# vim: ts=4
