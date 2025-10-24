-- NOTE: These 2 need to be set up before any plugins are loaded.
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Set highlight on search
vim.opt.hlsearch = false
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Make line numbers default
vim.wo.number = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Hide redundant mode text, rely on statusline instead
vim.o.showmode = false

-- Indent
vim.o.smarttab = true
vim.opt.cpoptions:append('I')
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2

-- stops line wrapping from being confusing
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,preview,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Provide richer terminal/window titles similar to legacy setup
vim.o.title = true

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd("FileType", {
  desc = "remove formatoptions",
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0
-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Moves Line Up' })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Moves Line Down' })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Scroll Down' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Scroll Up' })
vim.keymap.set("n", "n", "nzzzv", { desc = 'Next Search Result' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Previous Search Result' })

vim.keymap.set("n", "<leader><leader>[", "<cmd>bprev<CR>", { desc = 'Previous buffer' })
vim.keymap.set("n", "<leader><leader>]", "<cmd>bnext<CR>", { desc = 'Next buffer' })
vim.keymap.set("n", "<leader><leader>l", "<cmd>b#<CR>", { desc = 'Last buffer' })
vim.keymap.set("n", "<leader><leader>d", "<cmd>bdelete<CR>", { desc = 'delete buffer' })

-- see help sticky keys on windows
vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', ":bd <CR>", { desc = 'Close Buffer' })


-- You should instead use these keybindings so that they are still easy to use, but dont conflict
vim.keymap.set({ "n" }, '<C-q>', ':q! <CR>', { noremap = true, silent = true, desc = 'Quit!' })

vim.keymap.set({ "n", "v", "x" }, '<C-s>', ':update <CR>', { noremap = true, silent = true, desc = 'Save' })
vim.keymap.set({ "i" }, '<C-s>', '<Esc>:update <CR>', { noremap = true, silent = true, desc = 'Save' })

vim.keymap.set({ "v", "x", "n" }, '<leader>y', '"+y', { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({ "n", "v", "x" }, 'Y', '"+y', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({ "n", "v", "x" }, '<C-a>', 'gg0vG$', { noremap = true, silent = true, desc = 'Select all' })
vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+',
  { noremap = true, silent = true, desc = 'Paste from clipboard from within insert mode' })
vim.keymap.set("x", "<leader>P", '"_dP',
  { noremap = true, silent = true, desc = 'Paste over selection without erasing unnamed register' })


local function reload_config()
  local NS  = "myLuaConf"                                 -- <- your top-level namespace
  local ALT = vim.fn.expand("/Users/antoine.carnec/non-work/nvim-nix/config")       -- <- your alt config dir
  local INIT = ALT .. "/init.lua"

  -- sanity
  local function exists(p) return (vim.uv.fs_stat(p) ~= nil) end
  if not exists(ALT) or not exists(INIT) then
    vim.notify("ALT missing: " .. INIT, vim.log.levels.ERROR); return
  end

  -- keep ALT on rtp (so colors/ftplugin/etc. can be found if needed)
  pcall(function() vim.opt.rtp:remove(ALT) end)
  vim.opt.rtp:prepend(ALT)

  -- clear lazy/lze caches so plugin specs can be re-registered on reload
  pcall(function()
    local mod = package.loaded['lze']
    if type(mod) == 'table' and type(mod.clear_handlers) == 'function' then
      mod.clear_handlers()
    end
  end)
  for name, _ in pairs(package.loaded) do
    if name:match('^lazy') or name:match('^lze') or name:match('^lzextras') then
      package.loaded[name] = nil
    end
  end

  -- wrapper: for NS.* load strictly from ALT/lua, else fallback to original require
  local orig_require = require
  local function alt_require(mod)
    if mod == NS or mod:sub(1, #NS + 1) == NS .. "." then
      local rel = mod:gsub("%.", "/")
      local p1  = ALT .. "/lua/" .. rel .. ".lua"
      local p2  = ALT .. "/lua/" .. rel .. "/init.lua"
      local path = exists(p1) and p1 or (exists(p2) and p2 or nil)
      if not path then
        error(("not found in ALT for %s (checked %s and %s)"):format(mod, p1, p2))
      end
      -- drop stale cache for this module so we reload fresh
      package.loaded[mod]  = nil
      package.preload[mod] = nil
      local chunk, load_err = loadfile(path)
      if not chunk then error(load_err) end
      local out = chunk()  -- run module
      package.loaded[mod] = (out == nil) and true or out
      return package.loaded[mod]
    else
      return orig_require(mod)
    end
  end

  local ok, err
  _G.require = alt_require
  ok, err = pcall(dofile, INIT)
  _G.require = orig_require

  if not ok then
    vim.notify("Can't find reload config path:\n" .. err, vim.log.levels.ERROR)
  else
    vim.notify("Reload Config")
  end
end

vim.keymap.set("n", "<leader>rc", reload_config, { desc = "Reload [c]onfig" })
