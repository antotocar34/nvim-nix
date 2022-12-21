{
  pkgs,
  config,
  lib,
  ...
}:
with builtins;
with lib; let
  cfg = config.vim.vimwiki;
in {
  options.vim.vimwiki = {
    enable = mkEnableOption "Enable vimwiki";
    wikiPath = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["vimwiki"];
    vim.luaConfigRC.vimwiki = nvim.dag.entryAnywhere ''
      vim.g.vimwiki_list = {{ path="${cfg.wikiPath}" }}
      vim.g.vimwiki_global_ext = 0
    '';
  };
}
