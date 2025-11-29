return {
    "lualine.nvim",
    for_cat = 'general.always',
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(_)
      require('lualine').setup({
        options = {
          icons_enabled = true,
          theme = function()
            return vim.g.colors_name or nixCats("colorscheme")
          end,
          component_separators = { '⏽', '⏽' },
          section_separators = { '', '' },
          disabled_filetypes = { 'NvimTree', 'floaterm' },
        },
        sections = {
          lualine_a = {
            -- 'mode' 
          },
          lualine_b = {
            {
              'branch',
              separator = '',
            },
            -- 'diff',
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
            {
              'filetype',
              separator = '',
            },
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
  }
