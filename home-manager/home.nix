{
  config,
  pkgs,
  ...
}: let
  dots = "${config.home.homeDirectory}/dotfiles";
  liveLink = config.lib.file.mkOutOfStoreSymlink;
in {
  nixpkgs.config.allowUnfree = true;
  targets.genericLinux.enable = true;
  xdg.enable = true;

  home = {
    username = "josh";
    homeDirectory = "/home/josh";
    stateVersion = "24.11";

    packages = with pkgs; [
      bat
      delta
      fd
      fzf
      git
      gnumake
      jq
      mise
      neovim
      ripgrep
      stow
      tmux
      zsh
    ];

    file = {
      ".zshrc".source = liveLink "${dots}/shell/.zshrc";
      ".config/zsh".source = liveLink "${dots}/shell/.config/zsh";
      ".config/nvim".source = liveLink "${dots}/nvim/.config/nvim";
      ".tmux.conf".source = liveLink "${dots}/tmux/.tmux.conf";
      ".gitconfig".source = liveLink "${dots}/git/.gitconfig";
    };
  };

  programs.home-manager.enable = true;
  news.display = "silent";
}
