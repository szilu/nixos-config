{ config, pkgs, ...}:

{
	services = {
		flatpak.enable = true;
		gnome.gnome-keyring.enable = true;
		gvfs.enable = true;
		teamviewer.enable = true;
	};
	environment.systemPackages = with pkgs; [
		adwaita-icon-theme
		audacity
		brave
		#cura
		darktable
		evince
		ffmpeg
		firefox-wayland
		geeqie
		ghostty
		gimp3-with-plugins
		graphicsmagick-imagemagick-compat
		hunspellDicts.hu_HU
		htop
		inkscape
		jre_minimal
		kitty
		lazysql
		libreoffice
		librewolf
		logseq
		maim
		mpv
		pavucontrol
		pinsel
		qscreenshot
		retext
		sqlite
		telegram-desktop
		thunderbird
		transmission-remote-gtk
		turbovnc
		vlc
		wezterm
	];
}

# vim: ts=4
