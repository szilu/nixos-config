{ config, lib, pkgs, ...}:

{
	services.libinput.enable = true;

	xdg.portal = {
		enable = true;
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
		#extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ];
	};

	i18n.inputMethod = {
		enable = true;
		type = "fcitx5";
		#type = "ibus";
		fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ];
	};

	services.greetd = {
		enable = true;
		settings = rec {
			initial_session = {
				command = "${pkgs.hyprland}/bin/Hyprland";
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
	};

	environment.systemPackages = with pkgs; [
		blueman
		brightnessctl
		dmenu
		dunst
		flameshot
		grim
		hyprpaper
		hyprlandPlugins.hy3
		libnotify
		networkmanager_dmenu
		pamixer
		polkit_gnome
		slurp
		swaybg
		swayidle
		swaylock
		swaynotificationcenter
		waybar
		wl-clipboard
		wlogout
		wlr-randr
		wofi
		wtype
	];
}

# vim: ts=4
