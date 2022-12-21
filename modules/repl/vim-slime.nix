{
  pkgs,
  config,
  lib,
  ...
}:
with builtins;
with lib; let
  cfg = config.vim.repl.vim-slime;
in {
  options.vim.repl.vim-slime = {
    enable = mkEnableOption "Enable vim-slime";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["vim-slime"];

    vim.configRC.vim-slime = nvim.dag.entryAnywhere ''
      let g:slime_target = "neovim"
      let g:slime_python_ipython = 1
      vnoremap R :SlimeSend<CR>
      nnoremap R :SlimeSend<CR>j
    '';
  };
}
