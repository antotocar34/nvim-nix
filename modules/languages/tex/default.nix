{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.tex;
in {
  options.vim.languages.tex = {
    enable = mkEnableOption "enable tex support";
    vimtex.enable = mkEnableOption "enable vimtex";
  };

  config.vim = mkIf cfg.enable {
      startPlugins = [ "vimtex" ];

      configRC.tex = nvim.dag.entryAnywhere ''
      augroup texgroup
        au!
        autocmd FileType tex nnoremap <buffer> <F10> :VimtexCountWords<cr>
        autocmd FileType tex nnoremap <buffer> <leader>c I% <esc>
        autocmd FileType tex setlocal spell
        " Fold preamble in tex
        autocmd FileType tex nnoremap <leader>d ggv/\\noindent<CR>$zf``
        autocmd FileType tex nnoremap <leader>s :VimtexTocOpen <CR>
        autocmd FileType tex set nocindent nosmartindent noautoindent
        " Inkscape figures stuff
        " autocmd FileType tex inoremap <C-f> <Esc>: silent exec '.!inkscape-figures create "'.getline('.').'" "'.b:vimtex.root.'/figures/"'<CR><CR>:w<CR>
        " autocmd FileType tex nnoremap <C-f> : silent exec '!inkscape-figures edit "'.b:vimtex.root.'/figures/" > /dev/null 2>&1 &'<CR><CR>:redraw!<CR>
      augroup END
      '';

      luaConfigRC.vimtex = mkIf cfg.vimtex.enable (nvim.dag.entryAnywhere ''
        -- vim.api.nvim_create_autocmd("Filetype tex", {command = "packadd vimtex"})
        -- local vimtex_group = vim.api.nvim_create_augroup("vimtex", {clear = true})
        -- vim.api.nvim_create_autocmd("User VimtexEventQuit", {command = "VimtexClean", group=vimtex_group})
      ''
      );
      configRC.vimtex = mkIf cfg.vimtex.enable (nvim.dag.entryAnywhere ''
        let localleader = "\\"
        let maplocalleader = "\\"
        let g:tex_flavor='latex'
        let g:vimtex_view_method='zathura'
        let g:vimtex_quickfix_mode=0
        set conceallevel=0
        " let g:tex_conceal='abdmg'
        let g:vimtex_include_search_enabled=0
        let g:vimtex_complete_close_braces=1
        let g:vimtex_view_forward_search_on_start=0
        let g:vimtex_complete_close_braces = 1
        let g:vimtex_view_automatic = 0
        let g:vimtex_indent_enabled=0
        let g:vimtex_compiler_method='latexmk'
        let g:vimtex_compiler_latexmk = {
            \ 'options' : [
            \   '-pdf',
            \   '-shell-escape',
            \   '-verbose',
            \   '-file-line-error',
            \   '-synctex=1',
            \   '-interaction=nonstopmode',
            \ ],
            \}
        '');
  };
}

