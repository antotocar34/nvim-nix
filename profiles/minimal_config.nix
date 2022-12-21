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

  viAlias = true;
  vimAlias = false;
  hideSearchHighlight = true;
  tabWidth = 2;
  noShowMode = true;
  title = true;


  filetree.nvimTreeLua = {
    enable = true;
    closeOnFileOpen = true;
    openOnSetup = false;
    keyToggle = "-";
  };
  #
  filetype.nix.enable = true;
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

  configRC.autochdir = lib.nvim.dag.entryAnywhere ''
    set autochdir
  '';

  vnoremap = {
    "J" = ":m '>+1<CR>gv=gv";
    "K" = ":m '<-2<CR>gv=gv";
    "<C-d>" = "<C-d>zz";
    "<C-u>" = "<C-u>zz";
  };

  nvim-surround.enable = true;
}

