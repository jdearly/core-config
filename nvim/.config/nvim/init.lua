vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- fzf uses Neovim highlights; its bat preview uses Neovim's terminal palette.
vim.env.BAT_THEME = "ansi"

vim.pack.add({
  "https://github.com/junegunn/fzf.vim",
})

require("native_snippets").setup_filetype_snippets()

vim.opt.number = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.scrolloff = 8
vim.opt.previewheight = 8
vim.opt.confirm = true
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "gK", "K", { desc = "Keyword documentation" })
vim.keymap.set("n", "K", "<C-w>}", { desc = "Preview tag definition" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 128 })
  end,
})

local function grep_repository()
  vim.ui.input({ prompt = "rg> " }, function(query)
    if query == nil or query == "" then
      return
    end
    vim.cmd("silent grep! " .. vim.fn.shellescape(query))
    vim.cmd.copen()
  end)
end

local function run_make(arguments)
  vim.cmd.make({ args = arguments, bang = true })
  if vim.v.shell_error ~= 0 then
    vim.cmd.copen()
  end
end

local last_focused_test_name = nil

vim.keymap.set("n", "<leader>sf", "<cmd>Files<CR>", { desc = "Search files" })
vim.keymap.set("n", "<leader>sb", "<cmd>Buffers<CR>", { desc = "Search buffers" })
vim.keymap.set("n", "<leader>sg", "<cmd>Rg<CR>", { desc = "Search repository fuzzily" })
vim.keymap.set("n", "<leader>sq", grep_repository, { desc = "Search repository into quickfix" })

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

vim.keymap.set("n", "]q", "<cmd>cnext<CR>", { desc = "Next quickfix item" })
vim.keymap.set("n", "[q", "<cmd>cprevious<CR>", { desc = "Previous quickfix item" })
vim.keymap.set("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Open quickfix" })
vim.keymap.set("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Close quickfix" })
