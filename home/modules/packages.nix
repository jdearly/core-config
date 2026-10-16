{pkgs, ...}: {
  home.packages = with pkgs; [
    # Neovim is installed by programs.neovim in ./neovim.nix.
    alsa-scarlett-gui
    bat # https://github.com/sharkdp/bat
    calibre
    curl # https://curl.se/docs/
    delta # https://dandavison.github.io/delta/
    direnv # https://direnv.net/
    dmenu
    fd # https://github.com/sharkdp/fd
    firefox # https://www.mozilla.org/firefox/
    fzf # https://junegunn.github.io/fzf/
    gcc
    git # https://git-scm.com/docs
    gnumake # https://www.gnu.org/software/make/manual/
    htop
    jq # https://jqlang.org/manual/
    libnotify
    man-pages
    man-pages-posix
    nodejs # for tools that require it :(
    ripgrep # https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
    st
    stow # https://www.gnu.org/software/stow/manual/stow.html
    surf
    texstudio
    tmux # https://man.openbsd.org/tmux
    universal-ctags # https://docs.ctags.io/
    unzip
    xclip
    zsh # https://zsh.sourceforge.io/Doc/Release/
  ];
}
