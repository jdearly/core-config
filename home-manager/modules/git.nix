{...}: {
  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Josh Early";
    userEmail = "josh.early@protonmail.com";
  };
}
