{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.harpoon;
in {
  options.vim.harpoon = {
    enable = mkEnableOption "enable harpoon";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["harpoon"];

    vim.luaConfigRC.harpoon = nvim.dag.entryAnywhere ''
      require('harpoon').add_default_mappings()
    '';
  };
}
