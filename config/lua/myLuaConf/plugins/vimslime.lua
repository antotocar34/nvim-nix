return {
    "vim-slime",
    for_cat = 'general.extra',
    event = "DeferredUIEnter",
    before = function(_)
      vim.g.slime_no_mapping = 1
      vim.g.slime_get_jobid = function()
        -- iterate over all buffers to find the first terminal with a valid job
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_get_option_value('buftype',{buf = bufnr}) == "terminal" then
            if vim.fn.bufwinnr(bufnr) then
              local chan = vim.api.nvim_get_option_value( "channel",{buf = bufnr,})
              if chan and chan > 0 then
                return chan
              end
            end
          end
        end
        return nil
      end
      vim.g.slime_target = "neovim"
      vim.g.slime_suggest_default = false
      vim.g.slime_neovim_ignore_unlisted = false
      vim.keymap.set("x", "R", "<Plug>SlimeRegionSend", { buffer = true })
      vim.keymap.set( "n", "R", function()
        vim.cmd("SlimeSend")
        vim.cmd("normal! j")
      end)
    end,
}
