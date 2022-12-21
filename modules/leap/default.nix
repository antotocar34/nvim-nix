{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.leap;
in {
  options.vim.leap = {
    enable = mkEnableOption "enable leap";
  };

  config = mkIf cfg.enable {
      vim.startPlugins = [ "leap" ];

      vim.luaConfigRC.leap = nvim.dag.entryAnywhere ''
        require('leap').add_default_mappings()
      '';
  };
}
