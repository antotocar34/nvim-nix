{
pkgs,
lib,
config,
...
}: let
  l = lib // builtins;
  inherit (l) mkEnableOption mkIf nvim;
  cfg = config.vim.vim-beancount;
in {
  options.vim.vim-beancount = {
    enable = mkEnableOption "enable vim-beancount";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-beancount"];
  };
}


