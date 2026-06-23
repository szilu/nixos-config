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

	# Real login prompt (no autologin) so PAM can unlock the keyring with the
	# password you type here. tuigreet remembers the last user; just type pw.
	services.greetd = {
		enable = true;
		settings.default_session = {
			command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
			user = "greeter";
		};
	};

	# Secret Service wallet used by Brave/Chromium, unlocked at login via PAM.
	services.gnome.gnome-keyring.enable = true;
	security.pam.services.greetd.enableGnomeKeyring = true;

	programs.thunar = {
		enable = true;
		plugins = with pkgs; [ thunar-archive-plugin thunar-volman ];
	};

	programs.sway.enable = true;
	programs.hyprland = {
		enable = true;
		xwayland.enable = true;
	};

	#wayland.windowManager.hyprland = {
	#	extraConfig = ''
	#		plugin = ${hy3.packages.x86_64-linux.hy3}/lib/libhy3.so
	#	'';
	#};

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
		rose-pine-hyprcursor
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
