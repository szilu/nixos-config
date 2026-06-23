{ config, lib, pkgs, ...}:

let
	# Hyprland comes from nixpkgs (pkgs.hyprland, currently 0.55.3, cached).
	#
	# The hy3 plugin is the awkward part: upstream has only ever tagged hl0.55.0
	# (built for Hyprland 0.55.0), and nixpkgs ships that hy3-0.55.0 even though
	# its hyprland is 0.55.3. hy3 guards loading with an EXACT Hyprland-commit
	# check (COMPOSITOR_HASH != CLIENT_HASH -> "target hyprland version
	# mismatch"), so the 0.55.0 plugin refuses to load on the 0.55.3 compositor.
	# No published hy3 matches 0.55.3 anywhere, so there is no clean matched pair
	# to pin (flake or nixpkgs).
	#
	# hy3 compiles fine against the 0.55.3 headers (the plugin API is compatible
	# across these patch releases) — only the commit guard rejects it. So build
	# hy3 with HY3_NO_VERSION_CHECK defined (an `#ifndef` around the check in
	# src/main.cpp) to drop the guard. Tiny source build of hy3 only; hyprland
	# stays cached. Revisit / remove this override once upstream hy3 tags a
	# release for the 0.55.x Hyprland we run.
	hy3 = pkgs.hyprlandPlugins.hy3.overrideAttrs (prev: {
		preConfigure = (prev.preConfigure or "") + ''
			export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -DHY3_NO_VERSION_CHECK"
		'';
	});
in
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
			command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${config.programs.hyprland.package}/bin/start-hyprland";
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
		# package / portalPackage left at their defaults: pkgs.hyprland and
		# pkgs.xdg-desktop-portal-hyprland from nixos-26.05.
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
		hy3
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
