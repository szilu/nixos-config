{ config, pkgs, ... }: let
	#unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
	flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
	#hyprland = (import flake-compat {
	#	src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
	#}).defaultNix;

in {
	imports = [
		./hardware-configuration-harmony.nix
		./modules/base.nix
		./modules/apps.nix
		./modules/dev.nix
		./modules/hyprland.nix
		#./cachix.nix
	];

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
		permittedInsecurePackages = [ "electron-27.3.11" ];
	};

	boot = {
		#kernelPackages = pkgs.linuxPackages_latest;

		# Use the systemd-boot EFI boot loader.
		loader.systemd-boot.enable = true;
		loader.efi.canTouchEfiVariables = true;
	};

	networking = {
		networkmanager.enable = true;
		firewall.allowedTCPPorts = [ 22 ];
		# firewall.allowedUDPPorts = [ ... ];
	};

	users.users.szilu = {
		isNormalUser = true;
		extraGroups = [ "wheel" "docker" "vboxusers" "dialout" ];
	};

	time.timeZone = "Europe/Budapest";

	services = {
		blueman.enable = true;
		dbus.enable = true;
		rsyslogd.enable = true;

		avahi = {
			enable = true;
			nssmdns4 = true;
			openFirewall = true;
		};

		printing = {
			enable = true;
			drivers = [ pkgs.gutenprint ];
		};

		pipewire = {
			enable = true;
			alsa.enable = true;
			alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};

		pcscd = {
			enable = true;
			plugins = [ pkgs.pcsc-cyberjack ];
			extraArgs = [ "--disable-polkit" ];
		};
	};

	services.greetd.settings.initial_session.user = "szilu";

	#let
	#	unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
	#in {
	environment.systemPackages = with pkgs; [
		nodePackages.pnpm
		libnotify
		nodejs_20
	];

	fonts.fontDir.enable = true;
	fonts.packages = with pkgs; [
		liberation_ttf
		(nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono"]; })
		font-awesome
		google-fonts
	];

	# Some programs need SUID wrappers, can be configured further or are
	# started in user sessions.
	# programs.mtr.enable = true;
	# programs.gnupg.agent = {
	#	 enable = true;
	#	 enableSSHSupport = true;
	# };

	system.stateVersion = "23.05"; # Did you read the comment?
}

# vim: ts=4
