{ config, pkgs, ... }:

{
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
	};
	nixpkgs.config = {
		allowUnfree = true;
	};

	boot = {
		# Use the systemd-boot EFI boot loader.
		loader.systemd-boot.enable = true;
		loader.efi.canTouchEfiVariables = true;
	};

	networking = {
		networkmanager.enable = true;
		firewall.allowedTCPPorts = [ 22 1080 1443 3000 8080 8081 ];
		# firewall.allowedUDPPorts = [ ... ];
		hosts = {
			"127.0.0.1" = [ "dev-portal.eeszt.gov.hu" ];
			#"37.220.130.131" = [ "docutron.naturland.hu" "delivetron.naturland.hu" "trondroid.naturland.hu" ];
			"212.52.180.133" = [ "teszt2-portal.eeszt.gov.hu" "teszt2-www.eeszt.gov.hu" "teszt-mobil-if.eeszt.gov.hu" "teszt2-mobil-if.eeszt.gov.hu" ];
		};
	};

	users.users = {
		szilu = {
			isNormalUser = true;
			extraGroups = [ "wheel" "docker" "vboxusers" "dialout" ];
		};
		szilu-c = {
			isNormalUser = true;
			extraGroups = [ "docker" ];
		};
	};

	time.timeZone = "Europe/Budapest";

	services = {
		blueman.enable = true;
		dbus.enable = true;
		rsyslogd.enable = true;
		davfs2.enable = true;

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
			#alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};

		pcscd = {
			enable = true;
			plugins = [ pkgs.pcsc-cyberjack ];
		};

		rabbitmq = {
			enable = true;
			plugins = [ "rabbitmq_event_exchange" ];
			managementPlugin.enable = true;
		};
	};

	environment.systemPackages = with pkgs; [
		android-studio
		glaxnimate
		kicad-small
		kdePackages.kdenlive
		obs-studio
		telegram-desktop
		zoom-us
	];

	fonts.fontDir.enable = true;
	fonts.packages = with pkgs; [
		liberation_ttf
		pkgs.nerd-fonts.fira-code
		pkgs.nerd-fonts.droid-sans-mono
		font-awesome
		google-fonts
	];

	system.stateVersion = "23.05"; # Did you read the comment?
}

# vim: ts=4
