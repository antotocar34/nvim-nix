return {
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
      map('n', '+', '<cmd>FloatermNew --wintype=float --width=120 --height=40<CR>', 'New floating Floaterm')

      map('t', '<F3>', '<cmd>FloatermHide<CR><cmd>FloatermPrev<CR>', 'Previous Floaterm instance')
      map('t', '<F4>', '<cmd>FloatermHide<CR><cmd>FloatermNext<CR>', 'Next Floaterm instance')
      map('t', '¬', '<cmd>FloatermToggle<CR>', 'Toggle Floaterm window')
      map('t', '§', '<cmd>FloatermToggle<CR>', 'Toggle Floaterm window')
      map('t', '<C-w>h', '<C-\\><C-N><C-w>h', 'Terminal left window')
      map('t', '<C-w>j', '<C-\\><C-N><C-w>j', 'Terminal down window')
      map('t', '<C-w>k', '<C-\\><C-N><C-w>k', 'Terminal up window')
      map('t', '<C-w>l', '<C-\\><C-N><C-w>l', 'Terminal right window')
      map('t', '<C-q>', '<C-\\><C-N><cmd>FloatermKill<CR>', 'Kill Floaterm instance')
      map('t', '<C-k>[', function() vim.cmd("stopinsert") end, 'Leave terminal insert mode')

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
}
