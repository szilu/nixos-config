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
			./hardware-configuration.nix
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
		extraGroups = [ "wheel" "sudo" ];
		#packages = with pkgs; [
		#	firefox
		#	tree
		#];
	};

	nix.settings = {
		experimental-features = [ "nix-command" "flakes" ];
		substituters = ["https://hyprland.cachix.org"];
		trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
		auto-optimise-store = true;
		#packageOverrides = pkgs: {
		#	unstable = import <nixos-unstable> {
		#		config = config.nixpkgs.config;
		#	};
		#};
	};
	nixpkgs.config = { allowUnfree = true; };

	services.dbus.enable = true;
	services.rsyslogd.enable = true;

	services.printing.enable = true;
	services.teamviewer.enable = true;

	services.xserver = {
		enable = true;
		libinput.enable = true;
		#displayManager = {
		#	sddm.enable = true;
		#	autoLogin.enable = true;
		#	autoLogin.user = "szilu";
		#};
	};

	services.greetd = {
		enable = true;
		settings = rec {
			initial_session = {
				#command = "${unstable.hyprland}/bin/Hyprland";
				command = "${pkgs.hyprland}/bin/Hyprland";
				user = "szilu";
			};
			default_session = initial_session;
		};
	};

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

	services.locate = {
		enable = true;
		locate = pkgs.mlocate;
		localuser = null;
	};

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
	};
	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
		#extraPortals = [ unstable.xdg-desktop-portal-hyprland ];
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
		android-studio
		blueman
		borgbackup
		brave
		brightnessctl
		cachix
		compsize
		darktable
		#unstable.corepack
		nodePackages.pnpm
		dmenu
		file
		firefox-wayland
		gcc
		gimp
		git
		gparted
		hunspellDicts.hu_HU
		#unstable.hyprland
		#unstable.hyprpaper
		hyprpaper
		inkscape
		killall
		kitty
		libnotify
		libreoffice
		logseq
		mpv
		neovim
		networkmanager_dmenu
		nix-index
		nodejs_20
		pamixer
		pciutils
		skypeforlinux
		swaylock
		thunderbird
		usbutils
		vimPlugins.codeium-vim
		wlogout
		wofi
		#unstable.waybar
		waybar
		wget
		#unstable.xdg-desktop-portal-hyprland
	] ++ (if config.networking.hostName == "fanny" then [(blender.override { cudaSupport = true; })] else [blender]);

	fonts.fontDir.enable = true;
	# NixOS unstable
	#fonts.packages = with pkgs; [
	# NixOS 23.05
	fonts.fonts = with pkgs; [
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