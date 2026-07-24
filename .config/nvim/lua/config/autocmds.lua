-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Replace LazyVim's wrap_spell autocmd: keep wrap for all of them, but skip
-- spellcheck for markdown specifically (notes here mix Japanese/English and
-- technical terms, both of which spellcheck flags constantly).
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("custom_wrap_spell", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function(event)
    vim.opt_local.wrap = true
    if event.match ~= "markdown" then
      vim.opt_local.spell = true
    end

    -- Wide pipe tables look broken when soft-wrapped (render-markdown's
    -- box-drawing borders don't survive being cut mid-row). `wrap` is a
    -- window-wide setting, not per-line, so toggling it based on the
    -- cursor's exact row only fixed the one row the cursor happened to sit
    -- on -- every other table row was still wrapped and broken until the
    -- cursor landed on it. Instead, turn wrap off whenever a table is
    -- anywhere in the *visible* range of the window, so scrolling a table
    -- into view is enough (prose elsewhere still wraps once no table is
    -- on screen).
    if event.match == "markdown" then
      local buf = event.buf
      local table_ranges ---@type {[1]: integer, [2]: integer}[]?

      local function refresh_ranges()
        table_ranges = nil
        local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
        if not ok or not parser then
          table_ranges = {}
          return
        end
        local root = parser:parse()[1]:root()
        local query = vim.treesitter.query.parse("markdown", "(pipe_table) @table")
        table_ranges = {}
        for _, node in query:iter_captures(root, buf) do
          local start_row, _, end_row = node:range()
          table.insert(table_ranges, { start_row, end_row })
        end
      end

      local function update_wrap()
        if not table_ranges then
          refresh_ranges()
        end
        local win = vim.api.nvim_get_current_win()
        local top = vim.fn.line("w0", win) - 1
        local bottom = vim.fn.line("w$", win) - 1
        local visible = false
        for _, range in ipairs(table_ranges) do
          if range[1] <= bottom and range[2] >= top then
            visible = true
            break
          end
        end
        vim.wo[win].wrap = not visible
      end

      local group = vim.api.nvim_create_augroup("custom_markdown_table_nowrap_" .. buf, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled", "WinResized" }, {
        group = group,
        buffer = buf,
        callback = update_wrap,
      })
      vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        buffer = buf,
        callback = function()
          table_ranges = nil
        end,
      })
      update_wrap()
    end
  end,
})
