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
    ];

    # ---------------------------------------------------------------------------
    # Lua configuration
    # ---------------------------------------------------------------------------
    extraLuaConfig = builtins.readFile ../nvim/init.lua;
  };

  # ---------------------------------------------------------------------------
  # Snippet files — placed into ~/.config/nvim/luasnippets/ by Home Manager
  # ---------------------------------------------------------------------------
  xdg.configFile."nvim/lua/native_snippets.lua".source = ../nvim/lua/native_snippets.lua; 
  xdg.configFile."nvim/lua/native_snippets/c.lua".source = ../nvim/lua/native_snippets/c.lua; 
  xdg.configFile."nvim/lua/native_snippets/go.lua".source = ../nvim/lua/native_snippets/go.lua; 
  xdg.configFile."nvim/lua/native_snippets/python.lua".source = ../nvim/lua/native_snippets/python.lua; 
  xdg.configFile."nvim/lua/native_snippets/typescript.lua".source = ../nvim/lua/native_snippets/typescript.lua; 
  xdg.configFile."nvim/lua/markdown_wiki_links.lua".source = ../nvim/lua/markdown_wiki_links.lua; 
  }
