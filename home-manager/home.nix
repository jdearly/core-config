{...}: {
  imports = [
    ./modules/packages.nix
    ./modules/git.nix
    ./modules/tmux.nix
    ./modules/shell.nix
    ./modules/neovim.nix
    ./modules/wayland.nix
  ];

  home = {
    username = "josh";
    homeDirectory = "/home/josh";
    stateVersion = "24.11";
  };

  # Nicely reload system units when changing configs.
  systemd.user.startServices = "sd-switch";
}
