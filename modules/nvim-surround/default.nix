{
pkgs,
lib,
config,
...
}: let
  l = lib // builtins;
  inherit (l) mkEnableOption mkIf nvim;
  cfg = config.vim.nvim-surround;
in {
  options.vim.nvim-surround = {
    enable = mkEnableOption "enable nvim-surround.nvim";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [ "nvim-surround" ];

    vim.luaConfigRC.nvim-surround = nvim.dag.entryAnywhere ''
      require('nvim-surround').setup()
    '';
  };
}

