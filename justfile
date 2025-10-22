test:
  nix run . flake.nix

t ext:
  nix run . "./test_files/test.{{ext}}"

shell:
  nix shell .#nvim

rust-test:
  nix run .#nvim "./test_files/rust_demo/src/main.rs"

headless-log:
  result/bin/nvim --headless --cmd "set rtp^={{justfile_directory()}}" --cmd "set shadafile=" -u init.lua "+lua vim.api.nvim_exec_autocmds('User', { pattern = 'DeferredUIEnter' })" "+lua require('myLuaConf.headless').dump()" +qa

headless-nvimtree:
  result/bin/nvim --headless --cmd "set rtp^={{justfile_directory()}}" --cmd "set shadafile=" -u init.lua "+lua vim.api.nvim_exec_autocmds('User', { pattern = 'DeferredUIEnter' })" "+packadd nvim-tree-lua" "+NvimTreeToggle" "+lua require('myLuaConf.headless').dump()" +qa
