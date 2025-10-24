{
  description = "Antoine's neovim config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/e643668fd71b949c53f8626614b21ff71a07379d";
    nixCats.url = "github:BirdeeHub/nixCats-nvim"; 

    plugins-nord = {
      url = "github:antotocar34/nord.nvim";
      flake = false;
    };

    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };

  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = ./config;
    # this is flake-utils eachSystem
    forEachSystem = utils.eachSystem [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" "aarch64-linux"];
    extra_pkg_config = {
      allowUnfree = true;
    };
    # this allows you to use ${pkgs.system} whenever you want in those sections
    # without fear.

    # see :help nixCats.flake.outputs.overlays
    dependencyOverlays = /* (import ./overlays inputs) ++ */ [
      # This overlay grabs all the inputs named in the format
      # `plugins-<pluginName>`
      (utils.standardPluginOverlay inputs)
      # add any other flake overlays here.

    ];

    # see :help nixCats.flake.outputs.categories
    # and
    # :help nixCats.flake.outputs.categoryDefinitions.scheme
    categoryDefinitions = { pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {

      # lspsAndRuntimeDeps:
      # this section is for dependencies that should be available
      # at RUN TIME for plugins. Will be available to PATH within neovim terminal
      # this includes LSPs
      lspsAndRuntimeDeps = {
        # some categories of stuff.
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
        ];
        # these names are arbitrary.
        lint = with pkgs; [
          ruff
        ];
        # but you can choose which ones you want
        # per nvim package you export
        debug = with pkgs; {
          go = [ delve ];
        };
        bqls = [
          (pkgs.callPackage ./derivations/bqls.nix {})
        ];
        go = with pkgs; [
          gopls
          gotools
          go-tools
          gccgo
        ];
        python = with pkgs; [
          ruff
          pyright
        ];
        rust = with pkgs; [
          rust-analyzer
          rustc
          rustfmt
          clippy
          cargo
        ];
        # and easily check if they are included in lua
        # format = with pkgs; [
        # ];
        neonixdev = {
          # also you can do this.
          inherit (pkgs) nix-doc lua-language-server nixd;
          # and each will be its own sub category
        };
      };

      # This is for plugins that will load at startup without using packadd:
      startupPlugins = {
        debug = with pkgs.vimPlugins; [
          nvim-nio
        ];
        general = with pkgs.vimPlugins; {
          always = [
            lze
            lzextras
            vim-repeat
            plenary-nvim
            (nvim-notify.overrideAttrs { doCheck = false; }) # TODO: remove overrideAttrs after check is fixed
          ];
          extra = [
            nvim-web-devicons
          ];
        };
        # You can retreive information from the
        # packageDefinitions of the package this was packaged with.
        # :help nixCats.flake.outputs.categoryDefinitions.scheme
        themer = with pkgs.vimPlugins;
          (builtins.getAttr (categories.colorscheme or "onedark") {
              # Theme switcher without creating a new category
              "nord" = pkgs.neovimPlugins.nord;
              # "onedark" = onedark-nvim;
              # "catppuccin" = catppuccin-nvim;
              # "catppuccin-mocha" = catppuccin-nvim;
              # "tokyonight" = tokyonight-nvim;
              # "tokyonight-day" = tokyonight-nvim;
            }
          );
          # This is obviously a fairly basic usecase for this, but still nice.
      };

      # not loaded automatically at startup.
      # use with packadd and an autocommand in config to achieve lazy loading
      # or a tool for organizing this like lze or lz.n!
      # to get the name packadd expects, use the
      # `:NixCats pawsible` command to see them all
      optionalPlugins = {
        debug = with pkgs.vimPlugins; {
          # it is possible to add default values.
          # there is nothing special about the word "default"
          # but we have turned this subcategory into a default value
          # via the extraCats section at the bottom of categoryDefinitions.
          default = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
          go = [ nvim-dap-go ];
        };
        lint = with pkgs.vimPlugins; [
          nvim-lint
        ];
        format = with pkgs.vimPlugins; [
          conform-nvim
        ];
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
        ];
        neonixdev = with pkgs.vimPlugins; [
          lazydev-nvim
        ];
        general = {
          blink = with pkgs.vimPlugins; [
            luasnip
            cmp-cmdline
            blink-cmp
            blink-compat
            colorful-menu-nvim
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            # nvim-treesitter.withAllGrammars
            # This is for if you only want some of the grammars
            (nvim-treesitter.withPlugins (
              plugins: with plugins; [
                nix
                lua
                python
              ]
            ))
          ];
          telescope = with pkgs.vimPlugins; [
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            telescope-nvim
          ];
          always = with pkgs.vimPlugins; [
            nvim-lspconfig
            lualine-nvim
            gitsigns-nvim
            vim-sleuth
            vim-fugitive
            vim-rhubarb
            nvim-surround
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            # lualine-lsp-progress
            which-key-nvim
            comment-nvim
            nvim-tree-lua
            leap-nvim
            undotree
            vim-floaterm
            indent-blankline-nvim
            vim-startuptime
            # If it was included in your flake inputs as plugins-hlargs: pkgs.neovimPlugins.hlargs
          ];
        };
      };

      # shared libraries to be added to LD_LIBRARY_PATH
      # variable available to nvim runtime
      sharedLibraries = {
        general = [ # <- this would be included if any of the subcategories of general are
          # pkgs.libgit2
        ];
      };

      # get the path to this python environment
      # in your lua config via
      # vim.g.python3_host_prog
      # or run from nvim terminal via :!<packagename>-python3
      python3.libraries = {
        test = (_:[]);
      };

      # populates $LUA_PATH and $LUA_CPATH
      # $LUA_PATH exports paths so require() can find them
      # 
      extraLuaPackages = {
        general = [ (_:[]) ];
      };

      # see :help nixCats.flake.outputs.categoryDefinitions.default_values
      # this will enable test.default and debug.default
      # if any subcategory of test or debug is enabled
      extraCats = { };
    };


    # see :help nixCats.flake.outputs.packageDefinitions
    packageDefinitions = {
      # the name here is the name of the package
      # and also the default command name for it.
      nvim = { pkgs, name, ... }@misc: {
        # these also recieve our pkgs variable
        # see :help nixCats.flake.outputs.packageDefinitions
        settings = {
          suffix-path = true;
          suffix-LD = true;
          aliases = [ "vim" "vimcat" ];

          # :help nixCats.flake.outputs.settings for all of the settings available
          wrapRc = true;
          # wrapRc = "WRAPNEOVIM";
          # configDirName = "nixCats-nvim";
          unwrappedCfgPath = "/Users/antoine.carnec/non-work/nvim-nix";
          # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
          hosts.python3.enable = true;
          hosts.node.enable = true;
        };
        # enable the categories you want from categoryDefinitions
        categories = {
          markdown = true;
          general = true;
          lint = true;
          format = true;
          neonixdev = true;
          python = true;
          rust = true;
          # this does not have an associated category of plugins, 
          # but lua can still check for it
          lspDebugMode = false;
          # you could also pass something else:
          # see :help nixCats
          themer = true;
          colorscheme = "nord";
        };
        extra = {
          nixdExtras = {
            nixpkgs = ''import ${pkgs.path} {}'';
            # or inherit nixpkgs;
          };
        };
      };
    };

    defaultPackageName = "nvim";
  in
  forEachSystem (system: let
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit nixpkgs system dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
    pkgs = import nixpkgs { inherit system; };
  in {

    packages = (utils.mkAllWithDefault defaultPackage) // { derivations = (import ./derivations/default.nix pkgs);};
    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ defaultPackage ];
        inputsFrom = [ ];
        shellHook = ''
        '';
      };
    };

  });
}
