{
  pkgs,
  config,
  lib,
  ...
}:
with builtins;
with lib; let
  cfg = config.vim.filetype.nix;
in {
  options.vim.filetype.nix = {
    enable = mkEnableOption "Enable nix support through vim-nix";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-nix"];
  };
}
