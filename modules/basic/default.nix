{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim;
in {
  options.vim = {
    noShowMode = mkOption {
      type = types.bool;
      description = "Whether to show current mode on command line at bottom left";
    };
    title = mkOption {
      type = types.bool;
      description = "Names the window with a more descriptive title";
    };
  };

  config = {
    vim.noShowMode = mkDefault true;
    vim.title = mkDefault true;

    vim.configRC.basic = nvim.dag.entryAfter ["globalsScript"] ''
      ${optionalString cfg.noShowMode ''
        set noshowmode
      ''}
      ${optionalString cfg.title ''
        set title
      ''}
    '';
  };
}
