{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.vim.lsp;
in
{
  config.vim = lib.mkIf cfg.enable {
    nnoremap."<leader>lf" = ":lua vim.lsp.buf.format()<CR>"; 
  };
}
