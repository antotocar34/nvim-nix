return {
  "nvim-tree-lua",
  for_cat = 'general.extra',
  event = "DeferredUIEnter",
  before = function(_)
    -- Disable netrw to avoid clashing with nvim-tree
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  after = function(_)
    require('nvim-tree').setup({
      actions = {
        open_file = {
          quit_on_open = true,
        },
      },
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
    })

    vim.keymap.set('n', '-', '<cmd>NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
  end,
}
