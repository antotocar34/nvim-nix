{
  inputs = {
    neovim-flake.url = "github:antotocar34/neovim-flake?ref=custom_config";
    flake-utils.url = "github:numtide/flake-utils";
    _leap = {
      url = "github:ggandor/leap.nvim";
      flake = false;
    };
    _Comment = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    _nord = {
      url = "github:antotocar34/nord.nvim";
      # url = "/tmp/tmp.NYg84BP4Rt/nord.nvim";
      flake = false;
    };
    _vimwiki = {
      url = "github:vimwiki/vimwiki";
      flake = false;
    };
    _vim-floaterm = {
      url = "github:voldikss/vim-floaterm";
      flake = false;
    };
    _telescope-manix = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    _vim-slime = {
      url = "github:jpalardy/vim-slime";
      flake = false;
    };
    _toggle-lsp-diagnostics = {
      url = "github:WhoIsSethDaniel/toggle-lsp-diagnostics.nvim";
      flake = false;
    };
    _vim-nix = {
      url = "github:LnL7/vim-nix";
      flake = false;
    };
    _harpoon = {
      url = "github:ThePrimeagen/harpoon";
      flake = false;
    };
    _undotree = {
      url = "github:mbbill/undotree";
      flake = false;
    };
    _playground = {
      url = "github:nvim-treesitter/playground";
      flake = false;
    };
    _ultisnips = {
      url = "github:SirVer/ultisnips";
      flake = false;
    };
    _vimtex = {
      url = "github:lervag/vimtex";
      flake = false;
    };
    _nvim-colorizer = {
      url = "github:norcalli/nvim-colorizer.lua";
      flake = false;
    };
    _nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };
    _zen-mode = {
      url = "github:folke/zen-mode.nvim";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    neovim-flake,
    ...
  } @ inputs: 
  inputs.flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    l = pkgs.lib // builtins;

    customNeovim = configModule:
    neovim-flake.lib.neovimConfiguration {
          # A hack to load all plugins automatically
          # Finds all inputs that start with an underscore (these are plugins)
          # Remove the underscore and pass into extraInputs
          extraInputs = let
            startsWithUnderscore = string: !(l.isNull (l.match "_(.+)" string));
            plugins = l.filter startsWithUnderscore (l.attrNames inputs);
          in
          l.mapAttrs'
          (name: value: l.attrsets.nameValuePair (l.removePrefix "_" name) value)
          (l.genAttrs plugins (s: inputs.${s}));

          modules = let
            mkCfg = attrs: {config.vim = attrs;};
          in [
            (mkCfg configModule)
            ./modules
          ];

          inherit pkgs;
        };
        mkNeovim = path: (customNeovim (import path {inherit (neovim-flake) lib;})).neovim;
        mkNeovimAliases = {
          name,
          aliases,
          configPath,
        }: let
          mkNeovimAlias = path: alias: (
            pkgs.writeShellScriptBin alias
            "${(l.getExe (mkNeovim path))} $@"
            );
            in
            pkgs.symlinkJoin {
            inherit name;
            paths = map (mkNeovimAlias configPath) aliases;
            };
            neovimMax = mkNeovim ./config.nix;
            neovimMinimal = mkNeovimAliases {
            name = "neovim-minimal";
            aliases = ["vi" "nvim-min"];
            configPath = ./profiles/minimal_config.nix;
          };
  in {
    packages = {
      neovim = neovimMax;
      neovimMinimal = neovimMinimal;
    };
  });
  ## // {
  ##     # These outputs are independent of the system
  ##     nixosModules.defaults = import ./modules;
  ##     overlays.default = final: prev: {
  ##       nvim-nix = final.symlinkJoin {
  ##         name = "nvim-nix";
  ##         paths = [
  ##           (final.neovimMaxFor "aarch64-darwin")
  ##           (final.neovimMinimalFor "aarch64-darwin")
  ##         ]; # You might want to adjust this part based on your needs
  ##       };
  ##     };
  ##   };
  }

