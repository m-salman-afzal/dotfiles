-- VS Code (vscode-neovim) only, loaded from init.lua when vim.g.vscode is set.
local vscode = require('vscode')

--* Clipboard. vscode-neovim ships a provider that routes through VS Code's own
-- vscode.env.clipboard (runtime/vscode/clipboard.lua, loaded by `runtime! vscode/**`
-- from the --cmd-sourced vscode-neovim.vim, so it lands before init.lua) but only
-- auto-enables it on WSL. Opting in is what makes unnamedplus usable here: the default
-- provider is wl-copy, and GNOME exposes no wlr/ext-data-control, so wl-copy has to map
-- a toplevel and take keyboard focus to call wl_data_device.set_selection — that focus
-- bounce is the Peacock titlebar flash on every dd/yy/cc. Terminal nvim still gets
-- wl-copy, and still flashes; nothing to opt into there.
vim.g.clipboard = vim.g.vscode_clipboard

--* Undo. The one bare-key exception (terminal nvim keeps stock u): u / <C-r> walk VS
-- Code's undo stack, which steps per typing burst like Ctrl+Z. Insert-mode typing goes to
-- VS Code, not Nvim, so Nvim's own undo sees a whole insert session as one change.
vim.keymap.set('n', 'u', function() vscode.call('undo') end, { desc = 'undo (VS Code)' })
vim.keymap.set('n', '<C-r>', function() vscode.call('redo') end, { desc = 'redo (VS Code)' })

--* Mode badge, last item of the status bar's left group (lowest priority sorts
-- rightmost). VS Code lets an extension colour an item's background only with
-- statusBarItem.warningBackground / errorBackground (ALLOWED_BACKGROUND_COLORS in its
-- extension host), so INSERT takes warning and VISUAL/REPLACE take error, both recoloured
-- in settings.json; NORMAL has no box. An eval per actual change, never a settings.json
-- write (the old cursor-shape bug).
local letter = { n = 'N', i = 'I', v = 'V', V = 'V', ['\22'] = 'V', R = 'R', c = 'C' }
local box = { I = 'statusBarItem.warningBackground', V = 'statusBarItem.errorBackground', R = 'statusBarItem.errorBackground' }
local shown
local function badge(mode)
  local l = letter[mode:sub(1, 1)] or 'N' -- 'no' (operator pending) etc. read as normal
  if l == shown then return end
  shown = l
  vscode.eval_async([[
    const item = globalThis.vimModeBadge ??= vscode.window.createStatusBarItem('vim-mode-badge', vscode.StatusBarAlignment.Left, -100000)
    item.text = ` ${args.letter} `
    item.backgroundColor = args.box ? new vscode.ThemeColor(args.box) : undefined
    item.show()
  ]], { args = { letter = l, box = box[l] } })
end
vim.api.nvim_create_autocmd('ModeChanged', { callback = function() badge(vim.v.event.new_mode) end })
badge(vim.api.nvim_get_mode().mode)
