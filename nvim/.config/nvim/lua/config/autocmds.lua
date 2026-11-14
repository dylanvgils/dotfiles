-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Auto-update config
local AUTO_UPDATE_INTERVAL = 24 * 60 * 60 -- seconds
local AUTO_UPDATE_STAMP = vim.fn.stdpath("state") .. "/auto-update-last"

-- ESLint auto-fix on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.js", "*.ts", "*.jsx", "*.tsx" },
  command = "LspEslintFixAll",
})

-- Auto-update logic
local lazy_busy = false
local mason_pending = 0

local function set_status()
  vim.schedule(function()
    local parts = {}
    if lazy_busy then
      table.insert(parts, "󰒲 updating plugins")
    end
    if mason_pending > 0 then
      table.insert(parts, " updating " .. mason_pending .. " tools")
    end
    vim.g.auto_update_status = table.concat(parts, "  ")
  end)
end

local ok, lines = pcall(vim.fn.readfile, AUTO_UPDATE_STAMP)
local last = ok and tonumber(lines[1]) or 0

if os.time() - last > AUTO_UPDATE_INTERVAL then
  -- lazy.nvim
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyUpdatePre",
    once = true,
    callback = function()
      lazy_busy = true
      set_status()
    end,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyUpdate",
    once = true,
    callback = function()
      lazy_busy = false
      set_status()
    end,
  })
  require("lazy").update({ show = false })

  -- Mason
  local registry = require("mason-registry")
  local function done()
    mason_pending = math.max(mason_pending - 1, 0)
    set_status()
  end
  registry:on("package:install:success", done)
  registry:on("package:install:failed", done)

  registry.refresh(function()
    for _, pkg in ipairs(registry.get_installed_packages()) do
      local latest = pkg:get_latest_version()
      if pkg:get_installed_version() ~= latest and not pkg:is_installing() then
        mason_pending = mason_pending + 1
        pkg:install({ version = latest })
      end
    end
    set_status()
  end)

  vim.fn.writefile({ tostring(os.time()) }, AUTO_UPDATE_STAMP)
end
