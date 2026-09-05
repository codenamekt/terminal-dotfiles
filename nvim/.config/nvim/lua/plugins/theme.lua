-- Omarchy dynamic theme link or fallback for non-Omarchy systems
local omarchy_theme = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(omarchy_theme) == 1 then
  local ok, spec = pcall(dofile, omarchy_theme)
  if ok and type(spec) == "table" then
    return spec
  end
end

-- Fallback for non-Omarchy systems (e.g. Ubuntu): default to Catppuccin Mocha
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}

