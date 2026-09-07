{...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
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
}
