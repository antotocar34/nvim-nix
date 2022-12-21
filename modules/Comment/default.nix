{
  pkgs,
  lib,
  config,
  ...
}: let
  l = lib // builtins;
  inherit (l) mkEnableOption mkIf nvim;
  cfg = config.vim.Comment;
in {
  options.vim.Comment = {
    enable = mkEnableOption "enable Comment.nvim";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["Comment"];

    vim.luaConfigRC.Comment = nvim.dag.entryAnywhere ''
      require('Comment').setup()
    '';
  };
}
