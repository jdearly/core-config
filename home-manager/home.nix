{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  # Set Mod key for Sway
  mod = "Mod1";
in {
  imports = [
    # Modules from flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # Can also split up configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # Can add overlays here
    overlays = [
      # Add overlays for flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # Can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "josh";
    homeDirectory = "/home/josh";
  };

  # TODO: use programs.<program> with configuration
  # for anything that supports configuration
  home.packages = with pkgs; [
    alsa-scarlett-gui
    bat
    bemenu
    chromium
    direnv
    fzf
    gcc
    ghostty
    gnumake
    grim
    htop
    kitty
    libnotify
    man-pages
    mako
    nodejs # for tools that require it :(
    obsidian
    qutebrowser
    ripgrep
    slurp
    texstudio
    tmux
    unzip
    wl-clipboard
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      vim = "nvim";
    };
    history.size = 10000;

    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "refined";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; # This adds the hook to zsh
    nix-direnv.enable = true; # Better nix support
  };

  programs.neovim = {
    enable = true;
    # LSPs
    # May prefer dropping these in
    # project specific dev shells
    extraPackages = with pkgs; [
      # Language Servers
      bash-language-server
      gopls
      lua-language-server
      nixd
      pyright
      zls
      # Formatters
      alejandra
    ];
  };

  programs.swayr = {
    enable = true;
    systemd.enable = true;
  };

  programs.swayimg.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      terminal = "ghostty";
      keybindings = lib.mkOptionDefault {
        "${mod}+Ctrl+l" = "exec ${pkgs.swaylock-fancy}/bin/swaylock-fancy";
      };
      window.titlebar = false;
      floating.titlebar = false;
      input = {
        "type:keyboard" = {
          repeat_rate = "40";
          repeat_delay = "200";
        };
      };
      output = {
        "HDMI-A-1" = {
          mode = "2560x1440@144.0Hz";
        };
        "DP-3" = {
          mode = "1920x1080@144.0Hz";
        };
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = {};
    systemd.enable = true;
  };

  services.swayidle = {
    enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
