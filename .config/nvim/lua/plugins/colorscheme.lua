-- Let the terminal's own background show through, same as tmux (which never
-- draws its own background either -- see .config/tmux/tmux.conf's BG="default").
return {
  "folke/tokyonight.nvim",
  opts = {
    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
  },
}
