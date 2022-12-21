{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.autocomplete;
  toggleFunc = ''
    vim.g.cmp_toggle_flag = true -- initialize
    local normal_buftype = function()
      return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
    end
    toggle_completion = function()
      local ok, cmp = pcall(require, "cmp")
      if ok then
        local next_cmp_toggle_flag = not vim.g.cmp_toggle_flag
        if next_cmp_toggle_flag then
          print("completion on")
        else
          print("completion off")
        end
        cmp.setup({
          enabled = function()
            vim.g.cmp_toggle_flag = next_cmp_toggle_flag
            if next_cmp_toggle_flag then
              return normal_buftype
            else
              return next_cmp_toggle_flag
            end
          end,
        })
      else
        print("completion not available")
      end
    end
  '';
  toggleMappings = ''
    ["<C-k>"] = cmp.mapping({
      i = function()
        if cmp.visible() then
          cmp.abort()
          toggle_completion()
        else
          cmp.complete()
          toggle_completion()
        end
      end,
    }),
    -- ["<CR>"] = cmp.mapping({
    --   i = function(fallback)
    --     if cmp.visible() then
    --       cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
    --       toggle_completion()
    --     else
    --       fallback()
    --     end
    --   end,
    -- }),
  '';
in {
  config = mkIf cfg.enable {
    vim.nnoremap."<leader>." = ":lua toggle_completion()<CR>";
    vim.inoremap."<C-k>" = "<C-o>:lua toggle_completion()<CR>";

    vim.luaConfigRC.completion = mkIf (cfg.type == "nvim-cmp") (mkForce (nvim.dag.entryAnywhere ''

      ${toggleFunc}

      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local cmp = require'cmp'
      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        sources = {
          ${optionalString (config.vim.lsp.enable) "{ name = 'nvim_lsp' },"}
          ${optionalString (config.vim.lsp.rust.enable) "{ name = 'crates' },"}
          { name = 'vsnip' },
          { name = 'treesitter' },
          { name = 'path' },
          { name = 'buffer' },
        },
        mapping = {
          ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
          ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c'}),
          ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c'}),
          ['<C-y>'] = cmp.config.disable,
          ['<C-e>'] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
          }),
          ['<CR>'] = cmp.mapping.confirm({
            select = true,
          }),
          ['<C-n>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
              cmp.select_next_item()
            -- HACK ALERT
            elseif (vim.api.nvim_buf_get_option(0, "buftype") == "prompt") then
              cmp.select_next_item()
            elseif vim.fn['vsnip#available'](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
               cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-p>'] = cmp.mapping(function (fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn['vsnip#available'](-1) == 1 then
              feedkeys("<Plug>(vsnip-jump-prev)", "")
            else
              fallback()
            end
          end, { 'i', 's' }),
          ${toggleMappings}
        },
        completion = {
          completeopt = 'menu,menuone,noinsert, noselect',
        },
        formatting = {
          format = function(entry, vim_item)
            -- type of kind
            vim_item.kind = ${
        optionalString (config.vim.visuals.lspkind.enable)
        "require('lspkind').presets.default[vim_item.kind] .. ' ' .."
      } vim_item.kind

            -- name for each source
            vim_item.menu = ({
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              vsnip = "[VSnip]",
              crates = "[Crates]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        }
      })
      vim.cmd[[silent lua toggle_completion()]]
    ''));

    # TODO not sure about this one
    # ${optionalString (config.vim.autopairs.enable && config.vim.autopairs.type == "nvim-autopairs") ''
    # local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    # cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { text = ""} }))
    # ''}

    vim.snippets.vsnip.enable =
      if (cfg.type == "nvim-cmp")
      then true
      else config.vim.snippets.vsnip.enable;
  };
}
