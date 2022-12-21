test:
    nix flake update
    nix run .#neovim test.tex

update:
    nix profile remove $(nix profile list | rg neovim | cut -c1 | tr "\n" " ")
    nix profile install .#neovim .#neovimMinimal

run:
    nix run .#neovim test2.py

new name:
  #!/usr/bin/env bash
  mkdir {{justfile_directory()}}/modules/{{name}}
  touch {{justfile_directory()}}/modules/{{name}}/default.nix
  echo """
  {
  pkgs,
  lib,
  config,
  ...
  }: let
    l = lib // builtins;
    inherit (l) mkEnableOption mkIf nvim;
    cfg = config.vim.{{name}};
  in {
    options.vim.{{name}} = {
      enable = mkEnableOption \"enable {{name}}.nvim\";
    };

    config = mkIf cfg.enable {
      vim.startPlugins = [\"{{name}}\"];

      vim.luaConfigRC.{{name}} = nvim.dag.entryAnywhere ''
        require('{{name}}').setup()
      '';
    };
  }
  """ >> {{justfile_directory()}}/modules/{{name}}/default.nix

