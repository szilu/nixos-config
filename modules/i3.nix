{ config, pkgs, ...}:

{
	services.libinput.enable = true;

	services.displayManager = {
		# I3 config
		sddm.enable = true;
		autoLogin.enable = true;
		autoLogin.user = "szilu";
	};

	services.xserver = {
		enable = true;

		windowManager.i3 = {
			enable = true;
			extraPackages = with pkgs; [
				brightnessctl
				dunst
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
		config.common.default = "*";
		extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
	};

	i18n.inputMethod = {
		# enabled = "ibus";
		enabled = "fcitx5";
		fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-gtk ];
	};

	programs.dconf = {
		enable = true;
	};

	programs.thunar = {
		enable = true;
		plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
	};

	environment.systemPackages = with pkgs; [
		blueman
		ksnip
		libnotify
		pamixer
		swaylock
		wlogout
	];
}

# vim: ts=4
