{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.my-telescope;
  addIf = cond: elem:
    if cond
    then [elem]
    else [];
in {
  options.vim.my-telescope = {
    enable = mkEnableOption "Enable Custom Telescope config";

    subKey = mkOption {
      type = types.str;
      description = "Keybinding to initialize Telescope commands";
    };

    keyFindFiles = mkOption {
      type = types.str;
    };
    keyLiveGrep = mkOption {
      type = types.str;
    };
    keyBuffers = mkOption {
      type = types.str;
    };
    keyHelpTags = mkOption {
      type = types.str;
    };
    keyPickers = mkOption {
      type = types.str;
    };
    keyGitFindFiles = mkOption {
      type = types.str;
    };
    keyGitLiveGrep = mkOption {
      type = types.str;
    };
    keyGitGrepString = mkOption {
      type = types.str;
    };
    keyKeyMaps = mkOption {
      type = types.str;
    };
    plugins = {
      telescope-manix.enable = mkEnableOption "enable telescope-manix";
    };
  };

  config = mkIf (cfg.enable) {
    vim.startPlugins =
      [
        "telescope"
      ]
      ++ (addIf cfg.plugins.telescope-manix.enable "telescope-manix");

    vim.nnoremap =
      {
        "${cfg.subKey}${cfg.keyFindFiles}" = "<cmd> Telescope find_files<CR>";
        "${cfg.subKey}${cfg.keyGitFindFiles}" = "<cmd> Telescope git_files<CR>";
        "${cfg.subKey}${cfg.keyGitLiveGrep}" = ''
          <cmd>lua require('telescope.builtin').live_grep{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] }<cr>
        '';
        "${cfg.subKey}${cfg.keyGitGrepString}" = ''
          <cmd>lua require('telescope.builtin').grep_string{ cwd = vim.fn.systemlist("git rev-parse --show-toplevel")[1] }<cr>
        '';
        "${cfg.subKey}${cfg.keyLiveGrep}" = "<cmd> Telescope live_grep<CR>";
        "${cfg.subKey}${cfg.keyBuffers}" = "<cmd> Telescope buffers<CR>";
        "${cfg.subKey}${cfg.keyHelpTags}" = "<cmd> Telescope help_tags<CR>";
        "${cfg.subKey}${cfg.keyPickers}" = "<cmd> Telescope<CR>";
        "${cfg.subKey}${cfg.keyKeyMaps}" = "<cmd> Telescope keymaps<CR>";

        "${cfg.subKey}vcw" = "<cmd> Telescope git_commits<CR>";
        "${cfg.subKey}vcb" = "<cmd> Telescope git_bcommits<CR>";
        "${cfg.subKey}vb" = "<cmd> Telescope git_branches<CR>";
        "${cfg.subKey}vs" = "<cmd> Telescope git_status<CR>";
        "${cfg.subKey}vx" = "<cmd> Telescope git_stash<CR>";
      }
      // (
        if config.vim.lsp.enable
        then {
          "${cfg.subKey}lsb" = "<cmd> Telescope lsp_document_symbols<CR>";
          "${cfg.subKey}lsw" = "<cmd> Telescope lsp_workspace_symbols<CR>";

          "${cfg.subKey}lr" = "<cmd> Telescope lsp_references<CR>";
          "${cfg.subKey}li" = "<cmd> Telescope lsp_implementations<CR>";
          "${cfg.subKey}lD" = "<cmd> Telescope lsp_definitions<CR>";
          "${cfg.subKey}lt" = "<cmd> Telescope lsp_type_definitions<CR>";
          "${cfg.subKey}ld" = "<cmd> Telescope diagnostics<CR>";
        }
        else {}
      )
      // (
        if config.vim.treesitter.enable
        then {
          "${cfg.subKey}s" = "<cmd> Telescope treesitter<CR>";
        }
        else {}
      );

    vim.luaConfigRC.my-telescope = nvim.dag.entryAnywhere ''
      local telescope = require("telescope")
      telescope.setup {
        defaults = {
          vimgrep_arguments = {
            "${pkgs.ripgrep}/bin/rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case"
          },
          pickers = {
            find_command = {
              "${pkgs.fd}/bin/fd",
            },
          },
        }
      }
      ${
        optionalString cfg.plugins.telescope-manix.enable
        "telescope.load_extension('manix')"
      }
    '';
    vim.configRC.my-telescope = mkIf 
    (config.vim.autocomplete.enable && (config.vim.autocomplete.type == "nvim-cmp")) 
    (nvim.dag.entryAnywhere ''
      autocmd FileType TelescopePrompt lua require'cmp'.setup.buffer {
      \   completion = { autocomplete = false }
      \ }
    '');
  };
}
