if vim.fn.executable("helm") == 0 then
  return {}
end

return {
  {
    import = "lazyvim.plugins.extras.lang.helm",
  },
}
