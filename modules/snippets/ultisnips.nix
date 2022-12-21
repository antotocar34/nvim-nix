{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.snippets.ultisnips;
in {
  options.vim.snippets.ultisnips = {
    enable = mkEnableOption "Enable ultisnips";

    snippetDirectory = mkOption {
      description = "Path to directory where .snippet exist";
      type = types.str;
    };

    expandTrigger = mkOption {
      type = types.str ;
      default = "<tab>";
      description = "Key to expand snippet";
    };
  };


  config.vim = mkIf cfg.enable {
    optPlugins = ["ultisnips"];

    luaConfigRC.ultisnips = nvim.dag.entryAnywhere ''
      vim.g.UltiSnipsExpandTrigger = '${cfg.expandTrigger}'
      vim.g.UltiSnipsJumpForwardTrigger = '<tab>'
      vim.g.UltiSnipsJumpBackwardTrigger = '<s-tab>'
      vim.g.UltiSnipsSnippetDirectories = {'${cfg.snippetDirectory}'}
    '';

    configRC.ultisnips = mkIf config.vim.languages.tex.enable (nvim.dag.entryAnywhere ''
      autocmd FileType tex packadd ultisnips
    '');
  };
}
