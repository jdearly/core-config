{
  description = "Portable UNIX development environment";

  # Pin package and NixOS module behavior through flake.lock.
  # https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

  outputs = {nixpkgs, ...}: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    coreTools = pkgs.buildEnv {
      name = "unix-ide-core-tools";
      paths = import ./nix/core-packages.nix pkgs;
    };
  in {
    # `nix fmt` uses the same Nix formatter on every supported host.
    # https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-fmt
    # https://github.com/kamadorueda/alejandra
    formatter.x86_64-linux = pkgs.alejandra;

    # SteamOS cannot persist pacman packages across OS updates. This package
    # provides the core CLI through the persistent Nix store instead.
    # https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-profile-install
    packages.x86_64-linux = {
      core-tools = coreTools;
      default = coreTools;
    };

    # A consuming host combines this shared module with its generated hardware
    # module and host-specific settings.
    # https://nixos.org/manual/nixos/stable/#sec-writing-modules
    nixosModules.default = import ./nixos/configuration.nix;
  };
}
