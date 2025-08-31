{
pkgs,
lib,
config,
...
}: let
  l = lib // builtins;
  inherit (l) mkEnableOption mkIf nvim;
  cfg = config.vim.quarto;
in {
  options.vim.quarto = {
    enable = mkEnableOption "enable quarto.nvim";
  };

  # TODO implement conditional loading
  config = mkIf cfg.enable {
    vim.startPlugins = ["quarto-nvim" "otter"];

    vim.luaConfigRC.quarto = nvim.dag.entryAnywhere ''
      require('quarto').setup{
        debug = false,
        closePreviewOnExit = true,
        lspFeatures = {
          enabled = false,
          languages = { 'r', 'python', 'julia' },
          diagnostics = {
            enabled = true,
            triggers = { "BufWrite" }
          },
          completion = {
            enabled = false,
          },
        },
        keymap = {
          hover = 'K',
          definition = 'gd'
        }
      }
    '';
  };
}

