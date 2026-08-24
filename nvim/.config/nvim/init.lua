-- Neovim's Lua configuration entry point and API conventions:
-- https://neovim.io/doc/user/lua-guide.html

-- <Space> prefixes user-owned mappings.
-- https://neovim.io/doc/user/map.html#mapleader
vim.g.mapleader = " "

-- fzf.vim supplies file, buffer, and ripgrep pickers. vim.pack installs the
-- revision recorded in nvim-pack-lock.json. ANSI keeps bat previews aligned
-- with Neovim's terminal colors.
-- https://neovim.io/doc/user/pack.html#vim.pack
-- https://github.com/junegunn/fzf.vim
-- https://github.com/sharkdp/bat#customization
vim.env.BAT_THEME = "ansi"
vim.pack.add({
  "https://github.com/junegunn/fzf.vim",
})

-- Native snippets use Neovim's built-in snippet engine, not a plugin runtime.
-- https://neovim.io/doc/user/lua.html#vim.snippet
require("native_snippets").setup_filetype_snippets()

-- Markdown wiki links resolve repository-wide by unique file name.
-- https://neovim.io/doc/user/map.html#gf
require("markdown_wiki_links").setup()

-- Visible line numbers and wrapped-line indentation preserve source context.
-- Persistent undo keeps editing history across Neovim sessions.
-- https://neovim.io/doc/user/options.html#'number'
-- https://neovim.io/doc/user/options.html#'breakindent'
-- https://neovim.io/doc/user/options.html#'undofile'
vim.opt.number = true
vim.opt.breakindent = true
vim.opt.undofile = true

-- Use the system clipboard for normal yanks, deletes, changes, and puts.
-- Neovim delegates Wayland clipboard access to wl-copy and wl-paste.
-- https://neovim.io/doc/user/options.html#'clipboard'
-- https://neovim.io/doc/user/provider.html#clipboard
vim.opt.clipboard = "unnamedplus"

-- Ignore case unless the search contains uppercase characters.
-- https://neovim.io/doc/user/options.html#'ignorecase'
-- https://neovim.io/doc/user/options.html#'smartcase'
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- New splits open right/below, scrolling retains context, and destructive
-- commands request confirmation instead of failing.
-- https://neovim.io/doc/user/options.html#'splitright'
-- https://neovim.io/doc/user/options.html#'splitbelow'
-- https://neovim.io/doc/user/options.html#'scrolloff'
-- https://neovim.io/doc/user/options.html#'confirm'
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.confirm = true

-- Leave 'tags' at Neovim's default `./tags;,tags`: search the current file's
-- directory and each parent, then the working directory. Projects generate a
-- root `tags` file with Universal Ctags when symbol navigation is useful.
-- https://neovim.io/doc/user/options.html#'tags'
-- https://neovim.io/doc/user/tagsrch.html
-- https://docs.ctags.io/

-- :grep sends ripgrep's filename, line, column, and message output to quickfix.
-- https://neovim.io/doc/user/options.html#'grepprg'
-- https://neovim.io/doc/user/quickfix.html
-- https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md#automatic-filtering
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Escape also clears highlighted search matches.
-- https://neovim.io/doc/user/pattern.html#:nohlsearch
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Briefly highlight yanked text through a native event autocmd.
-- https://neovim.io/doc/user/autocmd.html#TextYankPost
-- https://neovim.io/doc/user/lua.html#vim.highlight.on_yank()
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 128 })
  end,
})

-- Prompt for a literal ripgrep query and put matches in quickfix. shellescape
-- prevents the query from becoming shell syntax.
-- https://neovim.io/doc/user/lua.html#vim.ui.input()
-- https://neovim.io/doc/user/builtin.html#shellescape()
local function grep_repository()
  vim.ui.input({ prompt = "rg> " }, function(query)
    if query == nil or query == "" then
      return
    end
    vim.cmd("silent grep! " .. vim.fn.shellescape(query))
    vim.cmd.copen()
  end)
end

-- :make uses the repository's Makefile contract and errorformat. Failed output
-- opens in quickfix for a single navigation path.
-- https://neovim.io/doc/user/quickfix.html#:make
local function run_make(arguments)
  vim.cmd.make({ args = arguments, bang = true })
  if vim.v.shell_error ~= 0 then
    vim.cmd.copen()
  end
end

local last_focused_test_name = nil

-- fzf.vim handles fuzzy discovery. The explicit grep path above handles stable
-- quickfix results.
-- https://github.com/junegunn/fzf.vim#commands
vim.keymap.set("n", "<leader>sf", "<cmd>Files<CR>", { desc = "Search files" })
vim.keymap.set("n", "<leader>sb", "<cmd>Buffers<CR>", { desc = "Search buffers" })
vim.keymap.set("n", "<leader>sg", "<cmd>Rg<CR>", { desc = "Search repository fuzzily" })
vim.keymap.set("n", "<leader>sq", grep_repository, { desc = "Search repository into quickfix" })

-- Every repository exposes check, verify, and focused-test Make targets. The
-- repeat mapping retains only process-local test-name state.
-- https://www.gnu.org/software/make/manual/make.html#Goals
vim.keymap.set("n", "<leader>mc", function()
  run_make({ "check" })
end, { desc = "Make check" })
vim.keymap.set("n", "<leader>mv", function()
  run_make({ "verify" })
end, { desc = "Make verify" })
vim.keymap.set("n", "<leader>mt", function()
  vim.ui.input({ prompt = "Test name> " }, function(test_name)
    if test_name ~= nil and test_name ~= "" then
      last_focused_test_name = test_name
      run_make({ "test-one", "TEST=" .. test_name })
    end
  end)
end, { desc = "Make focused test" })
vim.keymap.set("n", "<leader>mr", function()
  if last_focused_test_name == nil then
    vim.notify("No focused test has run", vim.log.levels.WARN)
    return
  end
  run_make({ "test-one", "TEST=" .. last_focused_test_name })
end, { desc = "Repeat focused test" })

-- Quickfix is the common navigation surface for grep and build failures.
-- https://neovim.io/doc/user/quickfix.html
vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
