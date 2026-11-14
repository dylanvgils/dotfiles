return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    opts.sections.lualine_x = opts.sections.lualine_x or {}
    table.insert(opts.sections.lualine_x, "filetype")

    table.insert(opts.sections.lualine_x, 1, {
      function()
        return vim.g.auto_update_status or ""
      end,
      cond = function()
        return (vim.g.auto_update_status or "") ~= ""
      end,
      color = { fg = "#7aa2f7" },
    })
  end,
}
