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

require('lze').load {
  { import = "myLuaConf.plugins.telescope", },
  { import = "myLuaConf.plugins.treesitter", },
  { import = "myLuaConf.plugins.completion", },
  { import = "myLuaConf.plugins.comment", },
  { import = "myLuaConf.plugins.leap", },
  { import = "myLuaConf.plugins.nvimtree", },
  {
    "markdown-preview.nvim",
    for_cat = 'general.markdown',
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle", },
    ft = "markdown",
    keys = {
      {"<leader>mp", "<cmd>MarkdownPreview <CR>", mode = {"n"}, noremap = true, desc = "markdown preview"},
      {"<leader>ms", "<cmd>MarkdownPreviewStop <CR>", mode = {"n"}, noremap = true, desc = "markdown preview stop"},
      {"<leader>mt", "<cmd>MarkdownPreviewToggle <CR>", mode = {"n"}, noremap = true, desc = "markdown preview toggle"},
    },
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
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
    "vim-floaterm",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    after = function(_)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
      end

      map('n', '¬', '<cmd>FloatermToggle<CR>', 'Toggle Floaterm window')
      map('n', '§', '<cmd>FloatermToggle<CR>', 'Toggle Floaterm window')
      map('n', '<F3>', '<cmd>FloatermHide<CR><cmd>FloatermPrev<CR>', 'Previous Floaterm instance')
      map('n', '<F4>', '<cmd>FloatermHide<CR><cmd>FloatermNext<CR>', 'Next Floaterm instance')
      map('n', '<leader>]', '<cmd>FloatermNew --wintype=vsplit --width=65<CR>', 'New Floaterm vsplit')
      map('n', '<leader>[', '<cmd>FloatermNew --wintype=split --height=15<CR>', 'New Floaterm split')
      map('n', '+', '<cmd>FloatermNew --wintype=float --width=180 --height=40<CR>', 'New floating Floaterm')

      map('t', '<F3>', '<cmd>FloatermHide<CR><cmd>FloatermPrev<CR>', 'Previous Floaterm instance')
      map('t', '<F4>', '<cmd>FloatermHide<CR><cmd>FloatermNext<CR>', 'Next Floaterm instance')
      map('t', '¬', '<cmd>FloatermToggle<CR>', 'Toggle Floaterm window')
      map('t', '§', '<cmd>FloatermToggle<CR>', 'Toggle Floaterm window')
      map('t', '<C-w>h', '<C-\\><C-N><C-w>h', 'Terminal left window')
      map('t', '<C-w>j', '<C-\\><C-N><C-w>j', 'Terminal down window')
      map('t', '<C-w>k', '<C-\\><C-N><C-w>k', 'Terminal up window')
      map('t', '<C-w>l', '<C-\\><C-N><C-w>l', 'Terminal right window')
      map('t', '<C-q>', '<C-\\><C-N><cmd>FloatermKill<CR>', 'Kill Floaterm instance')
      map('t', '<C-k>[', '<C-\\><C-N><CR>', 'Leave terminal insert mode')

      vim.g.floaterm_title = ''

      local floaterm_group = vim.api.nvim_create_augroup('myLuaConf.floaterm', { clear = true })
      local prev_win = -1

      local function apply_floaterm_highlights()
        if vim.g.colors_name == 'nord' then
          pcall(vim.api.nvim_set_hl, 0, 'Floaterm', { bg = '#2E3440' })
          pcall(vim.api.nvim_set_hl, 0, 'NormalFloat', { bg = '#2E3440' })
          pcall(vim.api.nvim_set_hl, 0, 'FloatermBorder', { fg = '#81A1C1' })
        end
      end

      vim.api.nvim_create_autocmd('ColorScheme', {
        group = floaterm_group,
        callback = apply_floaterm_highlights,
      })

      vim.api.nvim_create_autocmd('TermOpen', {
        group = floaterm_group,
        callback = function(args)
          apply_floaterm_highlights()
          vim.api.nvim_buf_call(args.buf, function()
            vim.opt_local.number = false
            vim.opt_local.relativenumber = false
            vim.opt_local.signcolumn = 'no'
            vim.cmd('startinsert')
          end)
        end,
      })

      vim.api.nvim_create_autocmd('TermEnter', {
        group = floaterm_group,
        callback = function()
          local channel = vim.bo.channel
          if channel ~= nil then
            vim.api.nvim_echo({ { string.format('jobid: %s', channel), 'Comment' } }, false, {})
          end
        end,
      })

      vim.api.nvim_create_autocmd('BufEnter', {
        group = floaterm_group,
        callback = function()
          if vim.bo.buftype == 'terminal' then
            local current_win = vim.api.nvim_get_current_win()
            if prev_win ~= current_win then
              vim.cmd('startinsert')
            end
            prev_win = current_win
          else
            prev_win = -1
          end
        end,
      })
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
    after = function(plugin)
      require('fidget').setup({
        notification = {
          window = {
            winblend = 40,
          },
        },
      })

      local function dim_fidget_notifications()
        pcall(vim.api.nvim_set_hl, 0, 'FidgetNotificationTitle', { link = 'Comment' })
        pcall(vim.api.nvim_set_hl, 0, 'FidgetNotification', { link = 'Comment' })
      end

      dim_fidget_notifications()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('myLuaConf.fidget.hls', { clear = true }),
        callback = dim_fidget_notifications,
      })
    end,
  },
  {
    "lualine.nvim",
    for_cat = 'general.always',
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (plugin)

      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = colorschemeName,
          component_separators = { '⏽', '⏽' },
          section_separators = { '', '' },
          disabled_filetypes = { 'NvimTree', 'floaterm' },
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = {
            {
              'branch',
              separator = '',
            },
            'diff',
          },
          lualine_c = {
            {
              'filename',
              path = 2,
            },
          },
          lualine_x = {
            {
              'diagnostics',
              sources = { 'nvim_lsp' },
              separator = '',
              symbols = { error = '', warn = '', info = '', hint = '' },
            },
            { 'filetype' },
            'hostname',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        -- tabline = {
        --   lualine_a = { 'buffers' },
        --   -- if you use lualine-lsp-progress, I have mine here instead of fidget
        --   -- lualine_b = { 'lsp_progress', },
        --   lualine_z = { 'tabs' }
        -- },
        extensions = {},
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
    after = function (plugin)
      require('gitsigns').setup({
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = '|' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
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
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
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
    after = function (plugin)
      require('which-key').setup({
      })
      require('which-key').add {
        { "<leader><leader>", group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[d]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>m", group = "[m]arkdown" },
        { "<leader>m_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>t", group = "[t]oggles" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true },
      }
    end,
  },
}

vim.cmd.colorscheme(colorschemeName)
