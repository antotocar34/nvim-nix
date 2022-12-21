{
  pkgs,
  lib,
  config,
  ...
}: let
  l = lib // builtins;
  inherit (l) mkEnableOption mkIf nvim;
  cfg = config.vim.nvim-colorizer;
in {
  options.vim.nvim-colorizer = {
    enable = mkEnableOption "enable nvim-colorizer.nvim";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["nvim-colorizer"];

    vim.luaConfigRC.nvim-colorizer = nvim.dag.entryAnywhere ''
      require('colorizer').setup()
    '';
  };
}
