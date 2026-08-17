vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
vim.opt.confirm = true
vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format buffer" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  callback = function()
    vim.highlight.on_yank({ timeout = 128 })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "Install semantic navigation for an attached language server",
  callback = function(event)
    local function map(keys, action, description)
      vim.keymap.set("n", keys, action, { buffer = event.buf, desc = description })
    end

    map("gd", vim.lsp.buf.definition, "Definition")
    map("gD", vim.lsp.buf.declaration, "Declaration")
    map("gr", vim.lsp.buf.references, "References")
    map("gi", vim.lsp.buf.implementation, "Implementation")
    map("K", vim.lsp.buf.hover, "Symbol documentation")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
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
  local output = vim.fn.systemlist(vim.list_extend({ "make" }, arguments))
  vim.fn.setqflist({}, "r", { title = table.concat(arguments, " "), lines = output })
  if vim.v.shell_error ~= 0 then
    vim.cmd.copen()
  end
end

vim.keymap.set("n", "<leader>sg", grep_repository, { desc = "Search repository" })
vim.keymap.set("n", "<leader>mv", function()
  run_make({ "verify" })
end, { desc = "Make verify" })
vim.keymap.set("n", "<leader>mt", function()
  vim.ui.input({ prompt = "Test name> " }, function(test_name)
    if test_name ~= nil and test_name ~= "" then
      run_make({ "test-one", "TEST=" .. test_name })
    end
  end)
end, { desc = "Make focused test" })
