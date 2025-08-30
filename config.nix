{lib}: {
  theme = {
    enable = true;
    name = "nord";
    supportedThemes."nord" = {
      setup = ''
        vim.g.nord_contrast = true
        vim.g.nord_italic = false
        vim.g.nord_bold = false

        require('nord').set()
        vim.cmd[[colorscheme nord]]
      '';
    };
  };

  leap.enable = true;
  Comment.enable = true;

  viAlias = false;
  vimAlias = true;
  hideSearchHighlight = true;
  tabWidth = 2;
  noShowMode = true;
  title = true;
  mapLeaderSpace = false;
  configRC.mapleader = ''
    let mapleader=" "
    let maplocalleader="\\"
  '';

  lsp = {
    enable = true;

    formatOnSave = false;

    lightbulb.enable = false;
    lspsaga.enable = false;
    nvimCodeActionMenu.enable = false;
    trouble.enable = true;
    lspSignature.enable = false;

    nix.enable = true;
    nix.formatter = "alejandra";

    python = false;
    clang.enable = false;
    rust.enable = false;
    sql = true;
    ts = false;
    go = false;
    toggleDiagnostics.enable = true;
    toggleDiagnostics.start_on = false; # TODO investigate this
  };

  visuals = {
    enable = true;
    nvimWebDevicons.enable = true;
    lspkind.enable = true;
    indentBlankline = {
      enable = false;
      fillChar = "";
      eolChar = "";
      showCurrContext = true;
    };
    cursorWordline = {
      enable = false;
      lineTimeout = 0;
    };
  };
  #
  autopairs.enable = true;
  #
  autocomplete = {
    enable = true;
    type = "nvim-cmp";
  };

  filetree.nvimTreeLua = {
    enable = true;
    closeOnFileOpen = true;
    openOnSetup = false;
    keyToggle = "-";
  };
  #
  tabline.nvimBufferline.enable = false;
  #
  treesitter = {
    enable = true;
    context.enable = false;
    highlight.enable = false;
    playground.enable = true;
  };

  keys = {
    enable = true;
    whichKey.enable = true;
  };
  #
  my-telescope = {
    enable = true;
    subKey = "<leader>j";
    keyFindFiles = "f";
    keyGitFindFiles = "g";
    keyGitLiveGrep = ";";
    keyGitGrepString = "w";
    keyBuffers = "b";
    keyLiveGrep = "l";
    keyHelpTags = "h";
    keyPickers = "t";
    keyKeyMaps = "k";
    plugins = {
      # TODO fix
      # telescope-manix.enable = false;
    };
  };
  #
  markdown = {
    enable = true;
    glow.enable = true;
  };

  git = {
    enable = true;
    gitsigns.enable = true;
  };
  #

  vim-floaterm = {
    enable = true;
  };

  #
  vimwiki = {
    enable = true;
    wikiPath = "~/Documents/Notes/vimwiki";
  };
  #
  filetype = {
    # tex.enable = false;
    nix.enable = true;
  };
  #
  repl = {
    vim-slime.enable = true;
  };

  languages = {
    tex  = {
      enable = true;
      vimtex.enable = true;
    };
  };

  snippets.ultisnips = {
    enable = true; # Massive input lag TODO fix this or switch to luasnip
    snippetDirectory = "/home/carneca/.config/nixpkgs/homedir/.config/nvim/my-snippets";
    expandTrigger = "<C-;>";
  };

  ## Keybindings
  nnoremap."<C-q>" = ":q<CR>";
  nnoremap."Y" = ''"+y'';
  vnoremap."Y" = ''"+y'';
  vnoremap."<C-s>" = "<Esc>:update <CR>";
  nnoremap."<C-s>" = "<Esc>:update <CR>";

  # " This is a spell check from gilles castel blog
  # https://castel.dev/post/lecture-notes-1/
  inoremap."<C-l>" = "<c-g>u<Esc>[s1z=`]a<c-g>u";
  # Toggle spell checking
  nnoremap."<leader>o" = "<cmd>set invspell<CR>";

  # Buffer remaps
  nnoremap."<C-l>" = ":bn<CR>";
  nnoremap."<C-h>" = ":bp<CR>";
  nnoremap."<leader>q" = ":bd<CR>";

  imap."<C-e>" = "<C-o>zz";

  configRC.yank = lib.nvim.dag.entryAnywhere ''
    augroup highlight_yank
     autocmd!
     au TextYankPost * silent! lua vim.highlight.on_yank{timeout=200}
    augroup END
  '';

  configRC.save_fold = lib.nvim.dag.entryAnywhere ''
    augroup remember_folds
    autocmd!
      autocmd BufWinLeave *.* mkview
      autocmd BufWinEnter *.* silent! loadview
    augroup END
  '';

  configRC.autochdir = lib.nvim.dag.entryAnywhere ''
    set autochdir
  '';

  vnoremap = {
    "J" = ":m '>+1<CR>gv=gv";
    "K" = ":m '<-2<CR>gv=gv";
    "<C-d>" = "<C-d>zz";
    "<C-u>" = "<C-u>zz";
  };

  statusline.my-lualine.enable = true;
  nvim-colorizer.enable = true;
  nvim-surround.enable = true;

  undotree.enable = true;
  zen-mode.enable = true;
}
