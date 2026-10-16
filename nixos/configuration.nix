{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = false;
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      flake-registry = "";
      nix-path = config.nix.nixPath;
      auto-optimise-store = true;
    };
    channel.enable = false;
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager.dwm.enable = true;
  };
  services.displayManager.defaultSession = "xfce+dwm";

  # Suspend on battery lid-close, but stay awake on AC or when docked.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    IdleAction = "ignore";
  };

  programs.dconf.enable = true;

  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    font-awesome
  ];

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;
    graceful = true;
  };

  boot.extraModprobeConfig = ''
    options snd_usb_audio vid=0x1235 pid=0x8212 device_setup=1
  '';

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  security.polkit.enable = true;

  programs.zsh.enable = true;
  programs.man.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit inputs outputs;};
    users.josh = import ../home/home.nix;
  };

  hardware.graphics = {
    enable = true;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  users.users.josh = {
    isNormalUser = true;
    description = "josh";
    extraGroups = ["networkmanager" "docker" "wheel"];
    shell = pkgs.zsh;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  system.stateVersion = "23.05"; # NOTE: leave at original install version; see above
}
