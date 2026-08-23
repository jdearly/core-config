pkgs:
# These host-level workflow tools are useful across projects. Language
# toolchains and analyzers stay in each project's devShell.
# Package lookup and metadata: https://search.nixos.org/packages
with pkgs; [
  bat # https://github.com/sharkdp/bat
  curl # https://curl.se/docs/
  delta # https://dandavison.github.io/delta/
  direnv # https://direnv.net/
  fd # https://github.com/sharkdp/fd
  firefox # https://www.mozilla.org/firefox/
  foot # https://codeberg.org/dnkl/foot
  fzf # https://junegunn.github.io/fzf/
  git # https://git-scm.com/docs
  gnumake # https://www.gnu.org/software/make/manual/
  jq # https://jqlang.org/manual/
  neovim # https://neovim.io/doc/
  ripgrep # https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md
  stow # https://www.gnu.org/software/stow/manual/stow.html
  tmux # https://man.openbsd.org/tmux
  universal-ctags # https://docs.ctags.io/
  zsh # https://zsh.sourceforge.io/Doc/Release/
]
