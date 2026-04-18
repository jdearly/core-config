{
  outputs,
  lib,
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
    calibre
    chromium
    direnv
    firefox
    fzf
    gcc
    ghostty
    gnumake
    grim
    htop
    libnotify
    mako
    man-pages
    nodejs # for tools that require it :(
    obsidian
    ripgrep
    slurp
    texstudio
    unzip
    vivaldi
    wl-clipboard
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Josh Early";
    userEmail = "josh.early@protonmail.com";
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [yank];
    extraConfig = ''
      set -sg escape-time 0 # get rid of escape delay in vim
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      unbind v
      unbind h

      unbind % # Split vertically
      unbind '"' # Split horizontally

      bind v split-window -h -c "#{pane_current_path}"
      bind h split-window -v -c "#{pane_current_path}"

      # set vi-mode
      set-window-option -g mode-keys vi
      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      set -g base-index 1
      setw -g pane-base-index 1

      unbind r
      bind r source-file ~/.tmux.conf \; display "Reloaded ~/.tmux.conf"

      unbind C-b
      set -g prefix C-Space

      set -g mouse on
      set -g set-clipboard external
    '';
  };

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
      lua-language-server
      nixd # Nix

      # Formatters
      stylua # Lua
      alejandra # Nix

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

      # Colorscheme
      kanagawa-nvim

      # Annotations / highlights
      todo-comments-nvim

      # Mini collection (ai, surround, statusline)
      mini-nvim

      # Treesitter — withAllGrammars keeps things simple;
      # swap for nvim-treesitter if you want to cherry-pick grammars.
      nvim-treesitter.withAllGrammars
    ];

    # ---------------------------------------------------------------------------
    # Lua configuration
    # ---------------------------------------------------------------------------
    extraLuaConfig = ''
      -- =========================================================================
      -- Options
      -- =========================================================================
      vim.g.mapleader      = ' '
      vim.g.maplocalleader = ' '
      vim.g.have_nerd_font = false

      vim.o.number       = true
      vim.o.mouse        = 'a'
      vim.o.showmode     = false
      vim.o.breakindent  = true
      vim.o.undofile     = true
      vim.o.ignorecase   = true
      vim.o.smartcase    = true
      vim.o.signcolumn   = 'yes'
      vim.o.updatetime   = 250
      vim.o.timeoutlen   = 300
      vim.o.splitright   = true
      vim.o.splitbelow   = true
      vim.o.list         = true
      vim.o.inccommand   = 'split'
      vim.o.cursorline   = true
      vim.o.scrolloff    = 10
      vim.o.confirm      = true

      vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

      vim.schedule(function()
        vim.o.clipboard = 'unnamedplus'
      end)

      -- =========================================================================
      -- Keymaps
      -- =========================================================================
      vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
      vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
      vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

      vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
      vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
      vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
      vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

      -- =========================================================================
      -- Autocommands
      -- =========================================================================
      vim.api.nvim_create_autocmd('TextYankPost', {
        desc     = 'Highlight when yanking (copying) text',
        group    = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
        callback = function()
          vim.hl.on_yank({ timeout = 128 })
        end,
      })

      -- =========================================================================
      -- gitsigns
      -- =========================================================================
      require('gitsigns').setup {
        signs = {
          add          = { text = '+' },
          change       = { text = '~' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '~' },
        },
      }

      -- =========================================================================
      -- which-key
      -- =========================================================================
      require('which-key').setup {
        delay = 0,
        icons = {
          mappings = vim.g.have_nerd_font,
          keys = vim.g.have_nerd_font and {} or {
            Up = '<Up> ', Down = '<Down> ', Left = '<Left> ', Right = '<Right> ',
            C = '<C-…> ', M = '<M-…> ', D = '<D-…> ', S = '<S-…> ',
            CR = '<CR> ', Esc = '<Esc> ',
            ScrollWheelDown = '<ScrollWheelDown> ', ScrollWheelUp = '<ScrollWheelUp> ',
            NL = '<NL> ', BS = '<BS> ', Space = '<Space> ', Tab = '<Tab> ',
            F1 = '<F1>', F2 = '<F2>', F3 = '<F3>', F4 = '<F4>',
            F5 = '<F5>', F6 = '<F6>', F7 = '<F7>', F8 = '<F8>',
            F9 = '<F9>', F10 = '<F10>', F11 = '<F11>', F12 = '<F12>',
          },
        },
        spec = {
          { '<leader>s', group = '[S]earch' },
          { '<leader>t', group = '[T]oggle' },
          { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        },
      }

      -- =========================================================================
      -- Telescope
      -- =========================================================================
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags,    { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps,      { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files,   { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin,      { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string,  { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep,    { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics,  { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume,       { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles,     { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10, previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep { grep_open_files = true, prompt_title = 'Live Grep in Open Files' }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })

      -- =========================================================================
      -- blink.cmp (completion)
      -- =========================================================================
      require('blink-cmp').setup {
        keymap    = { preset = 'default' },
        appearance = { nerd_font_variant = 'mono' },
        completion = {
          documentation = { auto_show = false, auto_show_delay_ms = 500 },
        },
        fuzzy     = { implementation = 'lua' },
        signature = { enabled = true },
      }

      -- =========================================================================
      -- LSP (nvim-lspconfig)
      -- =========================================================================
      vim.api.nvim_create_autocmd('LspAttach', {
        group    = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename,    '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references,              '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations,         '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions,             '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration,                                  '[G]oto [D]eclaration')
          map('gO',  require('telescope.builtin').lsp_document_symbols,        'Open Document Symbols')
          map('gW',  require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions,        '[G]oto [T]ype Definition')

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local hl_group = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf, group = hl_group,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf, group = hl_group,
              callback = vim.lsp.buf.clear_references,
            })
            vim.api.nvim_create_autocmd('LspDetach', {
              group    = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float         = { border = 'rounded', source = 'if_many' },
        underline     = { severity = vim.diagnostic.severity.ERROR },
        signs         = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN]  = '󰀪 ',
            [vim.diagnostic.severity.INFO]  = '󰋽 ',
            [vim.diagnostic.severity.HINT]  = '󰌶 ',
          },
        } or {},
        virtual_text  = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            return diagnostic.message
          end,
        },
      }

      local capabilities = require('blink-cmp').get_lsp_capabilities()

      local servers = {
        clangd = {
          cmd = {
            'clangd',
            '--background-index',
            '--clang-tidy',
            '--header-insertion=iwyu',
            '--completion-style=detailed',
            '--function-arg-placeholders',
            '--fallback-style=llvm',
          },
        },
        zls     = {},
        gopls   = {},
        pyright = {},
        lua_ls  = {
          cmd      = { 'lua-language-server' },
          filetypes = { 'lua' },
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
        nixd = {
          cmd = { 'nixd' },
          settings = {
            nixd = {
              nixpkgs = {
                expr = "import (builtins.getFlake(toString ./.)).inputs.nixpkgs { }",
              },
              formatting = {
                command = { 'alejandra' },
              },
            },
          },
        },
      }

      for server_name, server_config in pairs(servers) do
        server_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_config.capabilities or {})
        vim.lsp.config[server_name] = server_config
        vim.lsp.enable(server_name)
      end

      -- =========================================================================
      -- conform (formatting)
      -- =========================================================================
      require('conform').setup {
        notify_on_error = false,
        format_on_save  = function(bufnr)
          local disable_filetypes = { c = true, cpp = true }
          if disable_filetypes[vim.bo[bufnr].filetype] then
            return nil
          end
          return { timeout_ms = 500, lsp_format = 'fallback' }
        end,
        formatters_by_ft = {
          lua = { 'stylua' },
          nix = { 'alejandra' },
        },
      }

      -- =========================================================================
      -- Colorscheme (kanagawa)
      -- =========================================================================
      vim.cmd.colorscheme 'kanagawa-dragon'
      vim.cmd.hi 'Comment gui=none'
      vim.cmd.hi 'Normal ctermbg=none guibg=none'

      -- =========================================================================
      -- todo-comments
      -- =========================================================================
      require('todo-comments').setup { signs = false }

      -- =========================================================================
      -- mini.nvim
      -- =========================================================================
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup {}

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- =========================================================================
      -- nvim-treesitter
      -- =========================================================================
      require('nvim-treesitter.configs').setup {
        -- Grammars are managed by Nix (withAllGrammars), so no auto-install needed
        auto_install = false,
        highlight    = {
          enable = true,
          additional_vim_regex_highlighting = { 'ruby' },
        },
        indent       = { enable = true, disable = { 'ruby' } },
      }

      -- vim: ts=2 sts=2 sw=2 et
    '';
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
    style = ''
      * {
          border: none;
          border-radius: 0;
          font-family: Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
          min-height: 0;
      }

      window#waybar {
          background: rgba(43, 48, 59, 0.5);
          border-bottom: 3px solid rgba(100, 114, 125, 0.5);
          color: white;
      }

      tooltip {
        background: rgba(43, 48, 59, 0.5);
        border: 1px solid rgba(100, 114, 125, 0.5);
      }
      tooltip label {
        color: white;
      }

      #workspaces button {
          padding: 0 5px;
          background: transparent;
          color: white;
          border-bottom: 3px solid transparent;
      }

      #workspaces button.focused {
          background: #64727D;
          border-bottom: 3px solid white;
      }

      #mode, #clock, #battery {
          padding: 0 10px;
      }

      #mode {
          background: #64727D;
          border-bottom: 3px solid white;
      }

      #clock {
          background-color: #64727D;
      }

      #battery {
          background-color: #ffffff;
          color: black;
      }

      #battery.charging {
          color: white;
          background-color: #26A65B;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: black;
          }
      }

      #battery.warning:not(.charging) {
          background: #f53c3c;
          color: white;
          animation-name: blink;
          animation-duration: 0.5s;
          animation-timing-function: steps(12);
          animation-iteration-count: infinite;
          animation-direction: alternate;
      }
    '';
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
