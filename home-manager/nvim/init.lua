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
-- LuaSnip (snippet engine)
-- =========================================================================
local ls = require('luasnip')

ls.setup {
  history = true,                    -- remember last snippet to jump back
  update_events = 'TextChanged,TextChangedI', -- update dynamic nodes live
  delete_check_events = 'TextChanged',
}

-- Load custom Lua-format snippets managed by Home Manager
local snippet_path = (os.getenv('XDG_CONFIG_HOME') or (os.getenv('HOME') .. '/.config'))
  .. '/nvim/luasnippets'
require('luasnip.loaders.from_lua').lazy_load({
  paths = { snippet_path }
})

-- Load friendly-snippets (VSCode format) — these populate blink-cmp's
-- built-in snippets source. Custom LuaSnip Lua-format snippets above
-- supplement these with choice nodes and multi-line scaffolds.
require('luasnip.loaders.from_vscode').lazy_load()

-- Extend snippets to related filetypes
ls.filetype_extend('typescriptreact', { 'typescript' })
ls.filetype_extend('javascriptreact', { 'typescript' })
ls.filetype_extend('javascript',      { 'typescript' })
ls.filetype_extend('cpp',             { 'c' })

-- Cycle through choice nodes
vim.keymap.set({ 'i', 's' }, '<C-l>', function()
  if ls.choice_active() then ls.change_choice(1) end
end, { desc = 'Next snippet choice' })

vim.keymap.set({ 'i', 's' }, '<C-h>', function()
  if ls.choice_active() then ls.change_choice(-1) end
end, { desc = 'Previous snippet choice' })

-- =========================================================================
-- blink.cmp (completion)
-- =========================================================================
require('blink-cmp').setup {
  keymap = {
    preset = 'default',
    ['<Tab>']   = { 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
  },
  appearance = { nerd_font_variant = 'mono' },
  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },
  snippets = { preset = 'luasnip' },
  sources    = {
    default = { 'lsp', 'snippets', 'path', 'buffer' },
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
    init_options = {
      clangdFileStatus = true,
    },
  },
  zls = {
    settings = {
      zls = {
        enable_snippets          = true,
        enable_argument_placeholders = true,
        enable_autofix           = true,
        enable_import_detection  = true,
        warn_style              = true,
        highlight_global_var_declarations = true,
        inlay_hints_show_builtin  = true,
        inlay_hints_show_variable_type_hints = true,
        inlay_hints_show_parameter_name      = true,
      },
    },
  },
  gopls   = {
    settings = {
      gopls = {
        gofumpt       = true,
        staticcheck   = true,
        usePlaceholders = true,
        analyses = {
          unusedparams = true,
          shadow       = true,
          nilness      = true,
          unusedwrite  = true,
        },
        hints = {
          assignVariableTypes    = true,
          compositeLiteralFields = true,
          constantValues         = true,
          functionTypeParameters = true,
          parameterNames         = true,
          rangeVariableTypes     = true,
        },
      },
    },
  },
  pyright = {
    settings = {
      pyright = {
        disableOrganizeImports = true, -- let ruff handle imports
      },
      python = {
        analysis = {
          typeCheckingMode       = 'basic', -- 'off' | 'basic' | 'standard' | 'strict'
          autoSearchPaths        = true,
          useLibraryCodeForTypes = true,
          diagnosticMode         = 'openFilesOnly',
          inlayHints = {
            variableTypes       = true,
            functionReturnTypes = true,
            callArgumentNames  = 'partial',
            pytestParameters   = true,
          },
        },
      },
    },
  },
  ts_ls = {
    filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
    settings = {
      typescript = {
        updateImportsOnFileMove = { enabled = 'always' },
        completions = { completeFunctionCalls = true },
        inlayHints = {
          includeInlayParameterNameHints              = 'literals',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints      = true,
          includeInlayVariableTypeHints               = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints    = true,
          includeInlayFunctionLikeReturnTypeHints     = true,
          includeInlayEnumMemberValueHints            = true,
        },
      },
      javascript = {
        updateImportsOnFileMove = { enabled = 'always' },
        completions = { completeFunctionCalls = true },
        inlayHints = {
          includeInlayParameterNameHints              = 'literals',
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints      = true,
          includeInlayVariableTypeHints               = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayPropertyDeclarationTypeHints    = true,
          includeInlayFunctionLikeReturnTypeHints     = true,
          includeInlayEnumMemberValueHints            = true,
        },
      },
    },
  },
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
    local disable_filetypes = {}
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    end
    return { timeout_ms = 500, lsp_format = 'fallback' }
  end,
  formatters_by_ft = {
    lua        = { 'stylua' },
    nix        = { 'alejandra' },
    go         = { 'gofumpt', 'goimports' },
    c          = { 'clang_format' },
    cpp        = { 'clang_format' },
    typescript      = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    javascript      = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    python     = { 'ruff_format', 'ruff_organize_imports' },
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
  auto_install = false,
  highlight    = {
    enable = true,
    additional_vim_regex_highlighting = { 'ruby' },
  },
  indent       = { enable = true, disable = { 'ruby' } },
  textobjects  = {
    select = {
      enable    = true,
      lookahead = true,
      keymaps   = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',
        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',
      },
    },
    move = {
      enable              = true,
      set_jumps           = true,
      goto_next_start     = {
        [']f'] = '@function.outer',
        [']c'] = '@class.outer',
        [']a'] = '@parameter.inner',
      },
      goto_next_end       = {
        [']F'] = '@function.outer',
        [']C'] = '@class.outer',
      },
      goto_previous_start = {
        ['[f'] = '@function.outer',
        ['[c'] = '@class.outer',
        ['[a'] = '@parameter.inner',
      },
      goto_previous_end   = {
        ['[F'] = '@function.outer',
        ['[C'] = '@class.outer',
      },
    },
    swap = {
      enable        = true,
      swap_next     = { ['<leader>a'] = '@parameter.inner' },
      swap_previous = { ['<leader>A'] = '@parameter.inner' },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et