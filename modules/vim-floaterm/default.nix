{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.vim-floaterm;
in {
  options.vim.vim-floaterm = {
    enable = mkEnableOption "Add support for Toggle terminals";
  };

  config =
    mkIf (cfg.enable)
    {
      vim.startPlugins = ["vim-floaterm"];

      vim.nnoremap = {
        "¬" = "<cmd>FloatermToggle<CR>";
        "±" = "<cmd>FloatermToggle<CR>";
        "§" = "<cmd>FloatermToggle<CR>";
        "<F3>" = "<cmd>FloatermHide<CR><cmd>FloatermPrev<CR>";
        "<F4>" = "<cmd>FloatermHide<CR><cmd>FloatermNext<CR>";
        "<leader>]" = "<cmd>FloatermNew --wintype=vsplit --width=90<CR>";
        "<leader>[" = "<cmd>FloatermNew --wintype=split --height=15<CR>";
        "+" = "<cmd>FloatermNew --wintype=float --width=220 --height=60<CR>";
      };

      vim.tnoremap = {
        "<F3>" = "<cmd>FloatermHide<CR><cmd>FloatermPrev<CR>";
        "<F4>" = "<cmd>FloatermHide<CR><cmd>FloatermNext<CR>";
        "¬" = "<cmd>FloatermToggle<CR>";
        "±" = "<cmd>FloatermToggle<CR>";
        "§" = "<cmd>FloatermToggle<CR>";
        # "<leader>]" = "<cmd>FloatermNew --wintype=vsplit --width=90<CR>";
        # "<leader>[" = "<cmd>FloatermNew --wintype=split --height=15<CR>";
        "<C-w>h" = "<C-\\><C-N><C-w>h";
        "<C-w>j" = "<C-\\><C-N><C-w>j";
        "<C-w>k" = "<C-\\><C-N><C-w>k";
        "<C-w>l" = "<C-\\><C-N><C-w>l";
        "<C-q>" = "<C-\\><C-N><cmd>FloatermKill<CR>";
        "<C-k>[" = "<C-\\><C-n><CR>";
      };

      vim.globals.floaterm_title = "";

      vim.configRC.vim-floaterm = nvim.dag.entryAfter ["theme"] ''
        ${
          optionalString (config.vim.theme.name == "nord")
          ''
            " au TermOpen * hi! Floaterm guibg='#2E3440'
            au TermOpen * hi! NormalFloat guibg='#2E3440'
            hi FloatermBorder guifg='#81A1C1'
          ''
        }
          " Sane defaults for terminal
          au TermOpen * setlocal nonumber norelativenumber
          au TermOpen * startinsert
          au TermOpen * lua vim.wo.signcolumn="no"
          au TermEnter * echo "jobid: ". &channel

          " Auto insert into the terminal
          let g:previous_window = -1
          function SmartInsert()
            if &buftype == 'terminal'
              if g:previous_window != winnr()
                startinsert
              endif
              let g:previous_window = winnr()
            else
              let g:previous_window = -1
            endif
          endfunction

          au BufEnter * call SmartInsert()
      '';
    };
}
