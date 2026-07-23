-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- VSCode-familiar bindings, mapped onto LazyVim's existing pickers/explorer
-- (same functionality as <leader>ff / <leader>e / <leader>sC, just under the
-- muscle-memory keys VSCode uses).
local map = vim.keymap.set

map("n", "<C-p>", function() LazyVim.pick("files")() end, { desc = "Find Files" })
map("n", "<C-S-p>", function() Snacks.picker.commands() end, { desc = "Command Palette" })
map("n", "<C-b>", "<leader>e", { desc = "Toggle Explorer", remap = true })
