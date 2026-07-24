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
    -- Hidden files (dotfiles) and ignored ones (e.g. .git, gitignored) in
    -- the snacks.nvim explorer/picker both default to the "NonText" group
    -- (dark3, #545c7e), which is nearly unreadable on the transparent
    -- (near-black terminal) background. Use full-brightness fg instead,
    -- keeping italic as the "hidden/ignored" cue instead of low contrast.
    on_highlights = function(hl, c)
      hl.SnacksPickerPathHidden = { fg = c.fg, italic = true }
      hl.SnacksPickerPathIgnored = { fg = c.fg, italic = true }
    end,
  },
}
