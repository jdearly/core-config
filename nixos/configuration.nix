{pkgs, ...}: {
  # Project flakes require the modern `nix` command and flake subcommands.
  # https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Register Zsh as a valid login shell and install direnv with nix-direnv's
  # cached `use flake` integration.
  # https://search.nixos.org/options?show=programs.zsh.enable
  # https://search.nixos.org/options?show=programs.direnv.enable
  # https://github.com/nix-community/nix-direnv
  programs.zsh.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # NixOS owns the Docker daemon and its systemd service.
  # https://search.nixos.org/options?show=virtualisation.docker.enable
  virtualisation.docker.enable = true;

  # The shared personal account may administer the host and access Docker.
  # Host modules add hardware-specific groups such as networkmanager.
  # https://search.nixos.org/options?show=users.users.%3Cname%3E.isNormalUser
  users.users.josh = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = ["docker" "wheel"];
  };

  # Reuse the canonical core package set. Compose remains system-level because
  # it controls the Docker service declared above.
  # https://docs.docker.com/compose/
  environment.systemPackages =
    import ../nix/core-packages.nix pkgs
    ++ [pkgs.docker-compose];
}
