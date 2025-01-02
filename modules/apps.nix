{ config, pkgs, ...}:

{
	services = {
		flatpak.enable = true;
		gnome.gnome-keyring.enable = true;
		gvfs.enable = true;
		teamviewer.enable = true;
	};
	environment.systemPackages = with pkgs; [
		audacity
		brave
		#cura
		darktable
		evince
		ffmpeg
		firefox-wayland
		geeqie
		gimp-with-plugins
		adwaita-icon-theme
		hunspellDicts.hu_HU
		htop
		inkscape
		jre_minimal
		kicad-small
		kitty
		libreoffice
		logseq
		maim
		mpv
		pavucontrol
		pinsel
		qscreenshot
		retext
		skypeforlinux
		thunderbird
		transmission-remote-gtk
		turbovnc
		vlc
		wezterm
	];
}

# vim: ts=4
