{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.filetree.nvimTreeLua;
in {
  options.vim.filetree.nvimTreeLua = {
    keyToggle = mkOption {
      type = types.str;
      default = "<C-n>";
      description = "Key to open nvimtree";
    };
  };

  config = mkIf cfg.enable {
    vim.nnoremap = {
      "${cfg.keyToggle}" = ":NvimTreeToggle<CR>";
    };
  };
}
