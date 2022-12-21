{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.undotree;
in {
  options.vim.undotree = {
    enable = mkEnableOption "enable undotree";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["undotree"];

    vim.nnoremap."<leader>u" = ":UndotreeToggle<CR>";
  };
}
