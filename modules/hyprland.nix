{ config, lib, pkgs, ...}:

{
	services.libinput.enable = true;

	#services.xserver = {
	#	enable = true;
	#};

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

	#services.greetd = lib.mkDefault {
	services.greetd = {
		enable = true;
		settings = rec {
			initial_session = {
				#command = "${unstable.hyprland}/bin/Hyprland";
				command = "${pkgs.hyprland}/bin/Hyprland";
				#user = "szilu";
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
		#enableNvidiaPatches = if config.hardware.nvidia.nvidiaSettings then true else false;
	};

	environment.systemPackages = with pkgs; [
		blueman
		brightnessctl
		dmenu
		dunst
		grim
		libnotify
		hyprpaper
		hyprlandPlugins.hy3
		networkmanager_dmenu
		pamixer
		polkit_gnome
		slurp
		swaybg
		swayidle
		swaylock
		waybar
		wl-clipboard
		wlogout
		wlr-randr
		wofi
		wtype
	];
}

# vim: ts=4
