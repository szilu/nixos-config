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
		deno
		evince
		ffmpeg
		firefox-wayland
		geeqie
		gimp-with-plugins
		gnome.adwaita-icon-theme
		go
		hugo
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
		vlc
		wezterm
		zig
	];
}

# vim: ts=4
