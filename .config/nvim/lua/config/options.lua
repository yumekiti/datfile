-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LazyVim enables spell=true for markdown/gitcommit/etc with spelllang="en",
-- which flags every Japanese word as an unknown English word (red squiggles).
-- "cjk" tells Vim's spellchecker to skip words containing CJK characters
-- entirely instead of trying to match them against the English dictionary.
vim.opt.spelllang = { "en_us", "cjk" }

-- LazyVim defaults to relative line numbers (distance from cursor). Use
-- plain absolute numbering (1, 2, 3, ... from the top) instead.
vim.opt.relativenumber = false
