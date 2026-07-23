-- Multi-cursor editing, closest standalone-Neovim equivalent to VSCode's
-- Cmd/Ctrl+D "select next occurrence". Note: this is a *different* plugin
-- from vscode-multi-cursor.nvim, which only works inside the actual VSCode
-- app via the vscode-neovim extension and does nothing in a terminal.
--
-- Default trigger is <C-n> ("Find Under"), not <C-d>, since <C-d> is already
-- vim's half-page-down and remapping it globally would break normal
-- scrolling outside of a multi-cursor session.
return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
  },
}
