local colorschemeName = nixCats('colorscheme')
if not require('nixCatsUtils').isNixCats then
  colorschemeName = 'onedark'
end

local ok, notify = pcall(require, "notify")
if ok then
  notify.setup({
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  })
  vim.notify = notify
  vim.keymap.set("n", "<Esc>", function()
    notify.dismiss({ silent = true, })
  end, { desc = "dismiss notify popup and clear hlsearch" })
end

-- NOTE: you can check if you included the category with the thing wherever you want.
-- if nixCats('general.extra') then
-- end
-- For the first argument check :NixCats pawsible
require('lze').load {
  { import = "myLuaConf.plugins.telescope", },
  { import = "myLuaConf.plugins.treesitter", },
  { import = "myLuaConf.plugins.completion", },
  { import = "myLuaConf.plugins.comment", },
  { import = "myLuaConf.plugins.leap", },
  { import = "myLuaConf.plugins.nvimtree", },
  { import = "myLuaConf.plugins.floaterm", },
  { import = "myLuaConf.plugins.vimslime", },
  { import = "myLuaConf.plugins.lualine", },
  { import = "myLuaConf.plugins.bqls", },
  {
    -- autopairs
    "lexima.vim",
    for_cat = "general.extra",
    event = "DeferredUIEnter"
  },
  {
    "snacks",
    for_cat = "general.always",
    event = "DeferredUIEnter",
    after = function(_)
      local snacks = require("snacks")
      snacks.setup({
        input = {
          enable = true
        }
      }) 
    end

    
  },
  -- {
  --   "markdown-preview.nvim",
  --   for_cat = 'general.markdown',
  --   cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
  --   ft = "markdown",
  --   keys = {
  --     { "<leader>mp", "<cmd>MarkdownPreview <CR>",       mode = { "n" }, noremap = true, desc = "markdown preview" },
  --     { "<leader>ms", "<cmd>MarkdownPreviewStop <CR>",   mode = { "n" }, noremap = true, desc = "markdown preview stop" },
  --     { "<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = { "n" }, noremap = true, desc = "markdown preview toggle" },
  --   },
  --   before = function(plugin)
  --     vim.g.mkdp_auto_close = 0
  --   end,
  -- },
  {
    "undotree",
    for_cat = 'general.extra',
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo", },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" }, },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "indent-blankline.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(plugin)
      require("ibl").setup()
    end,
  },
  {
    "nvim-surround",
    for_cat = 'general.always',
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
  {
    "vim-startuptime",
    for_cat = 'general.extra',
    cmd = { "StartupTime" },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    -- TODO remove UI or reduce opacity
    "fidget.nvim",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(_)
      require('fidget').setup({
        progress = {
          display = {
            done_ttl = 1
          }
        },
        notification = {
          window = {
            winblend = 40,
          },
          override_vim_notify = true
        },
      })
    end,
  },
  {
    "gitsigns.nvim",
    for_cat = 'general.always',
    event = "DeferredUIEnter",
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('gitsigns').setup({
        -- See `:help gitsigns.txt`
        signs = {
          -- add          = { text = '|' },
          add          = { text = '▎' },
          change       = { text = '▎' },
          delete       = { text = '_' },
          topdelete    = { text = '‾' },
          changedelete = { text = '▎' },
        },
        sign_priority = 20,

        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          -- normal mode
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git [s]tage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git [r]eset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git [S]tage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = '[u]ndo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git [R]eset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = '[p]review git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git [b]lame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
        end,
      })
    end,
  },
  {
    "which-key.nvim",
    for_cat = 'general.extra',
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('which-key').setup({
      })
      require('which-key').add {
        { "<leader><leader>",  group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c",         group = "[c]ode" },
        { "<leader>c_",        hidden = true },
        { "<leader>d",         group = "[d]ocument" },
        { "<leader>d_",        hidden = true },
        { "<leader>g",         group = "[g]it" },
        { "<leader>g_",        hidden = true },
        { "<leader>m",         group = "[m]arkdown" },
        { "<leader>m_",        hidden = true },
        { "<leader>r",         group = "[r]ename" },
        { "<leader>r_",        hidden = true },
        { "<leader>s",         group = "[s]earch" },
        { "<leader>s_",        hidden = true },
        { "<leader>t",         group = "[t]oggles" },
        { "<leader>t_",        hidden = true },
        { "<leader>w",         group = "[w]orkspace" },
        { "<leader>w_",        hidden = true },
      }
    end,
  },
}

vim.cmd.colorscheme(colorschemeName)
