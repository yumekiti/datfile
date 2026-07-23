-- lazyvim.plugins.extras.lang.markdown (enabled in lazyvim.json) brings in
-- render-markdown.nvim for nicer in-buffer rendering, marksman LSP, and
-- prettier/markdownlint formatting/linting. It also bundles
-- markdown-preview.nvim, which was intentionally removed before (see git
-- history) since it opens a browser tab -- keep it disabled here.
--
-- markdownlint-cli2 (MD013 line-length, etc.) was too naggy, so it's dropped
-- from both linting and formatting, keeping prettier for formatting and
-- marksman for LSP features (completion/links/goto).
return {
  { "iamcco/markdown-preview.nvim", enabled = false },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft.markdown = nil
    end,
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft["markdown"] = { "prettier", "markdown-toc" }
      opts.formatters_by_ft["markdown.mdx"] = { "prettier", "markdown-toc" }
    end,
  },
}
