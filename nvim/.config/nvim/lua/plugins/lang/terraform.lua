if vim.fn.executable("terraform") == 0 then
  return {}
end

return {
  {
    import = "lazyvim.plugins.extras.lang.terraform",
  },
}
