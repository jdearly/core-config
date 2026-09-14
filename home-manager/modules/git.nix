{...}: {
  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings.user = {
      name = "Josh Early";
      email = "josh.early@protonmail.com";
    };
  };
}
