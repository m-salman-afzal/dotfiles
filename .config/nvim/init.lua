--* Options
vim.g.mapleader = ' ' -- must precede any <leader> mapping; leader is resolved at map time
vim.opt.clipboard = 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.opt.scrolloff = 5
vim.opt.virtualedit = 'onemore' -- let the cursor sit one past EOL, so backward deletes reach the last char


--* Cursor shape. vscode-neovim reads guicursor and applies it via editor.options
-- .cursorStyle (in-memory, no settings.json write — doing that from Lua on ModeChanged
-- was the previous bug here). It honours only block / ver (-> your editor.cursorStyle)
-- / hor (-> underline). block-outline is reachable only via editor.cursorStyle, i.e. for
-- the `ver` modes; visual is hardcoded to LineThin before either is consulted.
-- Sole deviation from the default is c:ver25 — command-line as a beam, not a block.
vim.opt.guicursor = 'n-v-sm:block,i-ci-ve-c:ver25,r-cr-o:hor20'

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

--* Clipboard. vscode-neovim ships a provider that routes through VS Code's own
-- vscode.env.clipboard (runtime/vscode/clipboard.lua, loaded by `runtime! vscode/**`
-- from the --cmd-sourced vscode-neovim.vim, so it lands before this file) but only
-- auto-enables it on WSL. Opting in is what makes unnamedplus usable here: the default
-- provider is wl-copy, and GNOME exposes no wlr/ext-data-control, so wl-copy has to map
-- a toplevel and take keyboard focus to call wl_data_device.set_selection — that focus
-- bounce is the Peacock titlebar flash on every dd/yy/cc. Terminal nvim still gets
-- wl-copy, and still flashes; nothing to opt into there.
if vim.g.vscode then
  vim.g.clipboard = vim.g.vscode_clipboard
end

--* Keymaps
-- ponytail: nothing on a bare key — personal maps go behind <leader> so stock motions
-- keep working on any box. "_ is the black hole register: delete without touching any
-- register, which matters here because unnamedplus sends every plain d/x/c to the
-- system clipboard.
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"_d', { desc = 'delete, no yank' })
vim.keymap.set({ 'n', 'x' }, '<leader>x', '"_x', { desc = 'delete char, no yank' })
vim.keymap.set({ 'n', 'x' }, '<leader>c', '"_c', { desc = 'change, no yank' })
