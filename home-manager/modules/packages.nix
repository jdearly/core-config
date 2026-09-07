{pkgs, ...}: {
  home.packages = with pkgs; [
    alsa-scarlett-gui
    bat
    bemenu
    calibre
    chromium
    direnv
    firefox
    foot
    fzf
    gcc
    ghostty
    gnumake
    grim
    htop
    libnotify
    mako
    man-pages
    nodejs # for tools that require it :(
    obsidian
    ripgrep
    slurp
    texstudio
    unzip
    vivaldi
    wl-clipboard
  ];
}
