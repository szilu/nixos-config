{ config, pkgs, ... }: let
	#unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
	flake-compat = builtins.fetchTarball "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
	#hyprland = (import flake-compat {
	#	src = builtins.fetchTarball "https://github.com/hyprwm/Hyprland/archive/master.tar.gz";
	#}).defaultNix;

in {
	imports = [
		./hardware-configuration-fanny.nix
		./modules/base.nix
		./modules/apps.nix
		./modules/dev.nix
		#./modules/i3.nix
		./modules/hyprland.nix
		#./cachix.nix
	];

	nix.settings = {
		experimental-features = [ "nix-command" "flakes" ];
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
		# Use the systemd-boot EFI boot loader.
		loader.systemd-boot.enable = true;
		loader.efi.canTouchEfiVariables = true;
	};

	networking = {
		networkmanager.enable = true;
		firewall.allowedTCPPorts = [ 22 3000 8080 8081 ];
		# firewall.allowedUDPPorts = [ ... ];
		hosts = {
			"127.0.0.1" = [ "dev-portal.eeszt.gov.hu" ];
		};
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
		davfs2.enable = true;

		greetd.settings.initial_session.user = "szilu";

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
		};
	};

	environment.systemPackages = with pkgs; [
		#(blender.override { cudaSupport = true; })
		android-studio
		#unstable.bun
		bun
		ffmpeg
		glaxnimate
		kicad-small
		libsForQt5.kdenlive
		nodePackages.pnpm
		nvidia-docker
		zoom-us
	];
	#++ (if config.networking.hostName == "fanny" then [(blender.override { cudaSupport = true; })] else [blender]);

	fonts.fontDir.enable = true;
	fonts.packages = with pkgs; [
		liberation_ttf
		#(nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono"]; })
		pkgs.nerd-fonts.fira-code
		pkgs.nerd-fonts.droid-sans-mono
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
