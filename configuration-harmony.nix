{ config, pkgs, ... }:

{
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
			#alsa.support32Bit = true;
			pulse.enable = true;
			jack.enable = true;
		};

		pcscd = {
			enable = true;
			plugins = [ pkgs.pcsc-cyberjack ];
			extraArgs = [ "--disable-polkit" ];
		};
	};

	environment.systemPackages = with pkgs; [
		libnotify
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
