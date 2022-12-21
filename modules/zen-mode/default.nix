
{
pkgs,
lib,
config,
...
}: let
  l = lib // builtins;
  inherit (l) mkEnableOption mkIf nvim;
  cfg = config.vim.zen-mode;
in {
  options.vim.zen-mode = {
    enable = mkEnableOption "enable zen-mode.nvim";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["zen-mode"];

    vim.luaConfigRC.zen-mode = nvim.dag.entryAnywhere ''
      require('zen-mode').setup()
    '';
  };
}

