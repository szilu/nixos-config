{ config, pkgs, ...}:

{
	services = {
		flatpak.enable = true;
		gnome.gnome-keyring.enable = true;
		gvfs.enable = true;
		teamviewer.enable = true;
	};
	environment.systemPackages = with pkgs; [
		brave
		#cura
		darktable
		evince
		firefox-wayland
		geeqie
		gimp-with-plugins
		gnome.adwaita-icon-theme
		hunspellDicts.hu_HU
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
		vlc
		wezterm
	];
}

# vim: ts=4
