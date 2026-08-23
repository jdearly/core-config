-- FileType autocmds install buffer-local insert mappings that expand Neovim's
-- native snippet syntax.
-- https://neovim.io/doc/user/lua.html#vim.snippet
-- https://neovim.io/doc/user/autocmd.html#FileType
-- https://neovim.io/doc/user/map.html#vim.keymap.set()
local NativeSnippets = {}

---@class NativeSnippet
---@field description string
---@field body string

---@type table<string, table<string, NativeSnippet>>
local snippets_by_filetype = {
  c = require("native_snippets.c"),
  go = require("native_snippets.go"),
  python = require("native_snippets.python"),
  typescript = require("native_snippets.typescript"),
}

function NativeSnippets.setup_filetype_snippets()
  local group = vim.api.nvim_create_augroup("NativeSnippetMappings", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    desc = "Install native snippet mappings for the current filetype",
    callback = function(event)
      local filetype_snippets = snippets_by_filetype[vim.bo[event.buf].filetype]
      if filetype_snippets == nil then
        return
      end

      for trigger, snippet in pairs(filetype_snippets) do
        local snippet_body = snippet.body
        vim.keymap.set("i", trigger, function()
          vim.snippet.expand(snippet_body)
        end, {
          buffer = event.buf,
          desc = snippet.description,
        })
      end
    end,
  })
end

return NativeSnippets
