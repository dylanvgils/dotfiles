if vim.fn.executable("java") == 0 then
  return {}
end

return {
  {
    import = "lazyvim.plugins.extras.lang.java",
  },
}
