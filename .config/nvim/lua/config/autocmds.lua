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
  end,
})
