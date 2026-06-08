if vim.fn.executable("go") ~= 1 then
  return {}
end

return {
  { import = "lazyvim.plugins.extras.lang.go" },
}
