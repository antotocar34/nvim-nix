{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter.playground;
in {
  options.vim.treesitter.playground = {
    enable = mkEnableOption "enable playground";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["playground"];

    vim.luaConfigRC.playground = nvim.dag.entryAnywhere ''
      require('leap').add_default_mappings()
    '';
  };
}
