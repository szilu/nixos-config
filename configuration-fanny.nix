# Edit this configuration file to define what should be installed on
# your system.	Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }: let
	#unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
	flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
	#hyprland = (import flake-compat {
	#	src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
	#}).defaultNix;

in {
	imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration-fanny.nix
			#./cachix.nix
		];

	# Use the systemd-boot EFI boot loader.
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.canTouchEfiVariables = true;

	networking = {
		networkmanager.enable = true;
	};

	time.timeZone = "Europe/Budapest";

	i18n.inputMethod = {
		# enabled = "ibus";
		enabled = "fcitx5";
		fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ];
	};

	users.users.szilu = {
		isNormalUser = true;
		extraGroups = [ "wheel" "sudo" "docker" ];
		#packages = with pkgs; [
		#	firefox
		#	tree
		#];
	};

	nix.settings = {
		experimental-features = [ "nix-command" "flakes" ];
		#substituters = ["https://hyprland.cachix.org"];
		#trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
		auto-optimise-store = true;
		#packageOverrides = pkgs: {
		#	unstable = import <nixos-unstable> {
		#		config = config.nixpkgs.config;
		#	};
		#};
	};
	nixpkgs.config = {
		allowUnfree = true;
		permittedInsecurePackages = [ "electron-24.8.6" ];
	};

	services.dbus.enable = true;
	services.rsyslogd.enable = true;
	services.flatpak.enable = true;
	services.gnome.gnome-keyring.enable = true;

	services.printing.enable = true;
	services.teamviewer.enable = true;

	services.xserver = {
		enable = true;
		libinput.enable = true;

		# I3 config
		displayManager = {
			sddm.enable = true;
			autoLogin.enable = true;
			autoLogin.user = "szilu";
		};
		windowManager.i3 = {
			enable = true;
			#package = pkgs.i3-rounded;
			extraPackages = with pkgs; [
				feh
				i3status
				i3lock
				i3blocks
				picom
				rofi
				xtitle
			];
		};
	};
	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
		#extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
		#extraPortals = [ unstable.xdg-desktop-portal-hyprland unstable.xdg-desktop-portal-gtk ];
		#extraPortals = [ unstable.xdg-desktop-portal-gtk ];
		#extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
	};

	# services.greetd = {
	# 	enable = true;
	# 	settings = rec {
	# 		initial_session = {
	# 			#command = "${unstable.hyprland}/bin/Hyprland";
	# 			#command = "${pkgs.hyprland}/bin/Hyprland";
	# 			command = "/run/current-system/sw/bin/Hyprland";
	# 			user = "szilu";
	# 		};
	# 		default_session = initial_session;
	# 	};
	# };

	hardware.bluetooth = {
		enable = true;
		powerOnBoot = true;
	};

	services.pipewire = {
		enable = true;
		alsa.enable = true;
		alsa.support32Bit = true;
		pulse.enable = true;
		jack.enable = true;
	};

	services.blueman = {
		enable = true;
	};

	services.gvfs.enable = true;

	services.locate = {
		enable = true;
		package = pkgs.mlocate;
		localuser = null;
	};

	virtualisation.docker = {
		enable = true;
		storageDriver = "btrfs";
		enableNvidia = true;
	};
	virtualisation.virtualbox.host.enable = true;
	users.extraGroups.vboxusers.members = [ "szilu" ];

	programs.nix-ld.enable = true;

	programs.neovim = {
		enable = true;
		defaultEditor = true;
		viAlias = true;
		vimAlias = true;
	};

	programs.sway.enable = true;
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		#package = unstable.hyprland;
		enableNvidiaPatches = true;
	};

	programs.thunar = {
		enable = true;
		plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
	};

	# List packages installed in system profile. To search, run:
	# $ nix search wget
	#let
	#	unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
	#in {
	environment.systemPackages = with pkgs; [
		#android-studio
		blueman
		blender.override { cudaSupport = true; }
		borgbackup
		brave
		brightnessctl
		cachix
		chromium
		compsize
		cura
		darktable
		dash
		dig
		dunst
		#unstable.corepack
		nodePackages.pnpm
		dmenu
		docker
		evince
		file
		firefox-wayland
		gcc
		geeqie
		gimp
		git
		gparted
		hunspellDicts.hu_HU
		#unstable.hyprland
		#unstable.hyprpaper
		hyprpaper
		inkscape
		jre_minimal
		kicad-small
		killall
		kitty
		libnotify
		libreoffice
		lm_sensors
		logseq
		mpv
		neovim
		networkmanager_dmenu
		nix-index
		nodejs_20
		nvidia-docker
		openssl
		pamixer
		pciutils
		#skypeforlinux
		swaylock
		thunderbird
		transmission-remote-gtk
		unzip
		usbutils
		vimPlugins.codeium-vim
		vlc
		wlogout
		wofi
		#unstable.waybar
		waybar
		wget
		#unstable.xdg-desktop-portal-hyprland
	]
	#++ (if config.networking.hostName == "fanny" then [(blender.override { cudaSupport = true; })] else [blender]);

	fonts.fontDir.enable = true;
	# NixOS unstable
	#fonts.packages = with pkgs; [
	# NixOS 23.05
	fonts.packages = with pkgs; [
		liberation_ttf
		#nerdfonts
		(nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono"]; })
		font-awesome
		google-fonts
	];
	#};

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };

	# List services that you want to enable:

	# Enable the OpenSSH daemon.
	services.openssh = {
		enable = true;
		#forwardX11 = true;
		settings.X11Forwarding = true;
	};

	# Open ports in the firewall.
	networking.firewall.allowedTCPPorts = [ 22 ];
	# networking.firewall.allowedUDPPorts = [ ... ];

	system.stateVersion = "23.05"; # Did you read the comment?

}

# vim: ts=4
