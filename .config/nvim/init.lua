--* Options
vim.g.mapleader = ' ' -- must precede any <leader> mapping; leader is resolved at map time
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.scrolloff = 5

--* Terminal-only UI (vscode-neovim draws its own)
if not vim.g.vscode then
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.signcolumn = 'yes'
  vim.opt.termguicolors = true
  vim.opt.expandtab = true
  vim.opt.shiftwidth = 2
  vim.opt.tabstop = 2
end

--* Keymaps
-- ponytail: none yet, and nothing on a bare key — personal maps go behind <leader> so
-- stock motions keep working on any box. vscode-neovim delegates LSP/files/search/git
-- to VS Code, so no plugin manager either.
