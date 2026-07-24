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
    -- Hidden files (dotfiles), gitignored files, and git-untracked files in
    -- the snacks.nvim explorer/picker all default to linking to "NonText"
    -- (see snacks.nvim's picker/config/highlights.lua: PathHidden,
    -- PathIgnored, and GitStatusUntracked/GitStatusIgnored all -> NonText).
    -- Even after NonText itself is brightened below, that's still visibly
    -- dimmer than a normal file entry's fg -- e.g. a plain untracked ".env"
    -- reads as "darker than its siblings" against this near-black bg. Use
    -- full-brightness fg for all four instead, keeping italic as the
    -- hidden/ignored/untracked cue in place of a dimmer color.
    on_highlights = function(hl, c)
      hl.SnacksPickerPathHidden = { fg = c.fg, italic = true }
      hl.SnacksPickerPathIgnored = { fg = c.fg, italic = true }
      hl.SnacksPickerGitStatusUntracked = { fg = c.fg, italic = true }
      hl.SnacksPickerGitStatusIgnored = { fg = c.fg, italic = true }

      -- tokyonight tunes its de-emphasis tones (dark3, dark5, fg_gutter,
      -- terminal_black) against its own bg (#222436). This config sets
      -- transparent=true and the real backdrop is the terminal's near-black
      -- background (config.ghostty's background = #010409), against which
      -- those tones fall well below WCAG's 4.5:1 text-contrast floor and
      -- read as "same color as the background". Rather than hunting down
      -- and re-listing every affected group by hand, walk every highlight
      -- tokyonight computed and, wherever one of those specific low-
      -- saturation dim tones is used as fg, brighten it enough to clear the
      -- bar against whatever it's actually rendered on (its own bg if it
      -- sets one dark enough to matter, otherwise the terminal background).
      -- Deliberately colored/semantic fg (diagnostics, git signs, syntax
      -- hues, ...) is never one of these exact values, so it's untouched
      -- even where its raw contrast number is similarly low -- a saturated
      -- red DiagnosticError is legible in a way a gray of the same
      -- luminance isn't, and recoloring it would erase its meaning.
      local function channel_luminance(v)
        v = v / 255
        if v <= 0.03928 then
          return v / 12.92
        end
        return ((v + 0.055) / 1.055) ^ 2.4
      end

      local function relative_luminance(hex)
        local r = tonumber(hex:sub(2, 3), 16)
        local g = tonumber(hex:sub(4, 5), 16)
        local b = tonumber(hex:sub(6, 7), 16)
        return 0.2126 * channel_luminance(r) + 0.7152 * channel_luminance(g) + 0.0722 * channel_luminance(b)
      end

      local function contrast_ratio(hex_a, hex_b)
        local la, lb = relative_luminance(hex_a), relative_luminance(hex_b)
        if la < lb then
          la, lb = lb, la
        end
        return (la + 0.05) / (lb + 0.05)
      end

      local function is_hex(color)
        return type(color) == "string" and color:match("^#%x%x%x%x%x%x$") ~= nil
      end

      local TERMINAL_BG = "#010409"
      local MIN_CONTRAST = 4.5
      -- luminance below this counts as "a dark UI panel", so we still fix
      -- text on it; anything brighter is treated as a deliberate colored
      -- badge (search/diagnostic backgrounds, etc.) and left untouched.
      local DARK_BG_LUMINANCE = 0.1
      local dim_tones = { c.dark3, c.dark5, c.fg_gutter, c.terminal_black, c.comment }
      local function is_dim_tone(hex)
        for _, tone in ipairs(dim_tones) do
          if hex:lower() == tone:lower() then
            return true
          end
        end
        return false
      end

      for _, spec in pairs(hl) do
        if type(spec) == "table" and is_hex(spec.fg) and is_dim_tone(spec.fg) and not spec.reverse then
          local effective_bg = is_hex(spec.bg) and spec.bg or TERMINAL_BG
          if relative_luminance(effective_bg) < DARK_BG_LUMINANCE then
            if contrast_ratio(spec.fg, effective_bg) < MIN_CONTRAST then
              -- fg_dark is the usual fix, but some groups pair a dim fg
              -- with a bg that's itself one of the theme's darker (but
              -- >black) tones, where fg_dark alone still doesn't clear
              -- the bar. Escalate to full-brightness fg in that case.
              spec.fg = c.fg_dark
              if contrast_ratio(spec.fg, effective_bg) < MIN_CONTRAST then
                spec.fg = c.fg
              end
            end
          end
        end
      end
    end,
  },
}
