local M = {}

local function wiki_link_target_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local cursor_column = vim.api.nvim_win_get_cursor(0)[2]
  local search_column = 1

  while search_column <= #line do
    local link_start, link_end, target = line:find("%[%[([^%]]+)%]%]", search_column)
    if link_start == nil then
      return nil
    end
    if cursor_column >= link_start - 1 and cursor_column <= link_end - 1 then
      return vim.trim(target)
    end
    search_column = link_end + 1
  end

  return nil
end

local function repository_root()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  local search_path = buffer_path ~= "" and buffer_path or vim.uv.cwd()
  return vim.fs.root(search_path, ".git")
end

local function is_repository_relative_path(target)
  if vim.startswith(target, "/") then
    return false
  end
  for path_segment in target:gmatch("[^/]+") do
    if path_segment == ".." then
      return false
    end
  end
  return true
end

local function resolve_wiki_link(repository, target)
  local markdown_path = vim.endswith(target, ".md") and target or target .. ".md"
  if markdown_path:find("/", 1, true) ~= nil then
    if not is_repository_relative_path(markdown_path) then
      return {}
    end
    local candidate = vim.fs.normalize(repository .. "/" .. markdown_path)
    local metadata = vim.uv.fs_stat(candidate)
    return metadata ~= nil and metadata.type == "file" and { candidate } or {}
  end

  return vim.fs.find(markdown_path, {
    path = repository,
    type = "file",
    limit = 2,
  })
end

local function follow_wiki_link()
  local target = wiki_link_target_at_cursor()
  if target == nil then
    vim.cmd("normal! gf")
    return
  end
  if target == "" then
    vim.notify("Empty wiki link", vim.log.levels.WARN)
    return
  end

  local root = repository_root()
  if root == nil then
    vim.notify("Wiki links require a Git repository", vim.log.levels.WARN)
    return
  end

  local matches = resolve_wiki_link(root, target)
  if #matches == 0 then
    vim.notify("Wiki link not found: " .. target, vim.log.levels.WARN)
    return
  end
  if #matches > 1 then
    vim.notify("Wiki link is ambiguous: " .. target, vim.log.levels.WARN)
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(matches[1]))
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    desc = "Navigate Markdown wiki links",
    callback = function(event)
      vim.keymap.set("n", "gf", follow_wiki_link, {
        buffer = event.buf,
        desc = "Follow wiki link or file",
      })
    end,
  })
end

return M
