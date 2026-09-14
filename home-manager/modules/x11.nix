{pkgs, ...}: let
  # Appearance single-source-of-truth
  cursorTheme = "Vanilla-DMZ-AA";
  cursorSize = 48;
  gtkTheme = "adw-gtk3-dark";
in {
  home.pointerCursor = {
    package = pkgs.vanilla-dmz;
    name = cursorTheme;
    size = cursorSize;
    x11.enable = true; # also writes Xcursor Xresources + exports env vars
    gtk.enable = true;
  };

  home.file.".icons/default/index.theme".text = ''
    [Icon Theme]
    Name=Default
    Comment=Default cursor theme
    Inherits=${cursorTheme}
  '';

  home.sessionVariables = {
    XCURSOR_SIZE = toString cursorSize;
    XCURSOR_THEME = cursorTheme;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    cursor-size = cursorSize;
    cursor-theme = cursorTheme;
  };

  xdg.configFile."xsettingsd/xsettingsd.conf".text = ''
    Gtk/CursorThemeName "${cursorTheme}"
    Gtk/CursorThemeSize ${toString cursorSize}
    Net/ThemeName "${gtkTheme}"
  '';

  gtk = {
    enable = true;
    theme = {
      name = gtkTheme;
      package = pkgs.adw-gtk3;
    };
    gtk4.theme = {
      name = gtkTheme;
      package = pkgs.adw-gtk3;
    };
    cursorTheme = {
      name = cursorTheme;
      size = cursorSize;
    };
  };

  xresources.properties = {
    "Xft.dpi" = 192;
    "Xft.antialias" = true;
    "Xft.hinting" = true;
  };

  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
  };
}
