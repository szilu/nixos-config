{ config, lib, pkgs, ...}:

{
	services.xserver = {
		enable = true;
		libinput.enable = true;
	};

	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
		#extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
		#extraPortals = [ unstable.xdg-desktop-portal-hyprland unstable.xdg-desktop-portal-gtk ];
		#extraPortals = [ unstable.xdg-desktop-portal-gtk ];
		#extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
	};

	i18n.inputMethod = {
		# enabled = "ibus";
		enabled = "fcitx5";
		fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ];
	};

	services.greetd = lib.mkDefault {
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

	programs.thunar = {
		enable = true;
		plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
	};

	programs.sway.enable = true;
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
		#package = unstable.hyprland;
		enableNvidiaPatches = true;
	};

	environment.systemPackages = with pkgs; [
		blueman
		brightnessctl
		dmenu
		dunst
		libnotify
		hyprpaper
		networkmanager_dmenu
		pamixer
		swaylock
		wlogout
		wofi
		waybar
	];
}

# vim: ts=4
