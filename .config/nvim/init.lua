-- Shared by terminal Nvim and VS Code (vscode-neovim). The entry point: editor-specific
-- config lives in lua/host/terminal.lua and lua/host/vscode.lua, required at the bottom.
-- (Not lua/vscode.lua: that would shadow vscode-neovim's own require('vscode') module.)

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

--* Keymaps
-- ponytail: nothing on a bare key — personal maps go behind <leader> so stock motions
-- keep working on any box. "_ is the black hole register: delete without touching any
-- register, which matters here because unnamedplus sends every plain d/x/c to the
-- system clipboard.
vim.keymap.set({ 'n', 'x' }, '<leader>d', '"_d', { desc = 'delete, no yank' })
vim.keymap.set({ 'n', 'x' }, '<leader>x', '"_x', { desc = 'delete char, no yank' })
vim.keymap.set({ 'n', 'x' }, '<leader>c', '"_c', { desc = 'change, no yank' })

--* Editor-specific config, after the shared part so it sees mapleader and the options
require(vim.g.vscode and 'host.vscode' or 'host.terminal')
