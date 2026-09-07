{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # ---------------------------------------------------------------------------
    # LSP servers, formatters, and tools available on PATH inside Neovim
    # ---------------------------------------------------------------------------
    extraPackages = with pkgs; [
      # LSP servers
      clang-tools # clangd
      zls # Zig
      gopls # Go
      pyright # Python
      typescript-language-server # TypeScript
      lua-language-server
      nixd # Nix

      # Formatters
      stylua # Lua
      alejandra # Nix
      gofumpt # Go (stricter gofmt)
      gotools # Go (goimports)
      prettierd # TypeScript / JS
      ruff # Python (formatter + linter)

      # Telescope dependencies
      ripgrep
      fd

      # Treesitter needs a C compiler for grammar compilation
      gcc
    ];

    # ---------------------------------------------------------------------------
    # Plugins — Nix manages fetching; we call setup() in extraLuaConfig below
    # ---------------------------------------------------------------------------
    plugins = with pkgs.vimPlugins; [
      # Utilities / dependencies
      plenary-nvim
      nvim-web-devicons

      # Indent detection
      guess-indent-nvim

      # Git signs
      gitsigns-nvim

      # Keymap hints
      which-key-nvim

      # Fuzzy finder
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim

      # LSP
      nvim-lspconfig
      fidget-nvim # LSP progress UI

      # Formatting
      conform-nvim

      # Completion
      blink-cmp

      # Snippets
      luasnip
      friendly-snippets

      # Colorscheme
      kanagawa-nvim

      # Annotations / highlights
      todo-comments-nvim

      # Mini collection (ai, surround, statusline)
      mini-nvim

      # Treesitter — withAllGrammars keeps things simple
      nvim-treesitter.withAllGrammars
      nvim-treesitter-textobjects
    ];

    # ---------------------------------------------------------------------------
    # Lua configuration
    # ---------------------------------------------------------------------------
    extraLuaConfig = builtins.readFile ../nvim/init.lua;
  };

  # ---------------------------------------------------------------------------
  # Snippet files — placed into ~/.config/nvim/luasnippets/ by Home Manager
  # ---------------------------------------------------------------------------
  xdg.configFile."nvim/luasnippets/go.lua".source = ../nvim/luasnippets/go.lua;
  xdg.configFile."nvim/luasnippets/typescript.lua".source = ../nvim/luasnippets/typescript.lua;
  xdg.configFile."nvim/luasnippets/python.lua".source = ../nvim/luasnippets/python.lua;
  xdg.configFile."nvim/luasnippets/c.lua".source = ../nvim/luasnippets/c.lua;
}
