{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
  t = types;
  boolToString = bool:
    if bool
    then "true"
    else "false";
in {
  options.vim.lsp.toggleDiagnostics = {
    enable = mkEnableOption "";
    start_on = mkOption {
      type = t.bool;
      description = "whether lsp diagnostics start on or not";
      default = true;
    };
  };

  config = mkIf (cfg.enable && cfg.toggleDiagnostics.enable) {
    vim.startPlugins = ["toggle-lsp-diagnostics"];

    vim.luaConfigRC.toggleDiagnostics = nvim.dag.entryAnywhere ''
      require 'toggle_lsp_diagnostics'.init({ start_on = ${boolToString cfg.toggleDiagnostics.start_on}})
    '';

    vim.nnoremap."<leader>," = "<Plug>(toggle-lsp-diag)";
    # vim.nnoremap."<leader>tlu" = "<Plug>(toggle-lsp-diag-underline)";
    # vim.nnoremap."<leader>tls" = "<Plug>(toggle-lsp-diag-signs)";
    # vim.nnoremap."<leader>tlv" = "<Plug>(toggle-lsp-diag-vtext)";
    # vim.nnoremap."<leader>tlp" = "<Plug>(toggle-lsp-diag-update_in_insert)";
    # vim.nnoremap."<leader>tldd" = "<Plug>(toggle-lsp-diag-default)";
    # vim.nnoremap."<leader>tldo" = "<Plug>(toggle-lsp-diag-off)";
    # vim.nnoremap."<leader>tldf" = "<Plug>(toggle-lsp-diag-on)";
  };
}
