function! myspacevim#before() abort
  call SpaceVim#logger#info("bootstrap_after called")     " log bootstrap_after call

  " fix too long of a delay after hitting ESC to get back into normal mode
  set ttimeoutlen=10
  set timeoutlen=1000

  " allow jk to exit into normal mode in terminal buffer
  tnoremap jk <Esc>

  " \ as leader is weird in a latin keyboard
  let g:mapleader = ','

  " https://github.com/yuki-yano/fzf-preview.vim#vim-script-rpc-1

  "nnoremap <silent> [fzf-p]p     :<C-u>FzfPreviewFromResourcesRpc project_mru git<CR>
  "nnoremap <silent> [fzf-p]gs    :<C-u>FzfPreviewGitStatusRpc<CR>
  "nnoremap <silent> [fzf-p]b     :<C-u>FzfPreviewBuffersRpc<CR>
  "nnoremap <silent> [fzf-p]B     :<C-u>FzfPreviewAllBuffersRpc<CR>
  "nnoremap <silent> [fzf-p]o     :<C-u>FzfPreviewFromResourcesRpc buffer project_mru<CR>
  "nnoremap <silent> [fzf-p]<C-o> :<C-u>FzfPreviewJumpsRpc<CR>
  "nnoremap <silent> [fzf-p]g;    :<C-u>FzfPreviewChangesRpc<CR>
  "nnoremap <silent> [fzf-p]/     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
  "nnoremap <silent> [fzf-p]*     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
  "nnoremap          [fzf-p]gr    :<C-u>FzfPreviewProjectGrepRpc<Space>
  "xnoremap          [fzf-p]gr    "sy:FzfPreviewProjectGrepRpc<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
  "nnoremap <silent> [fzf-p]t     :<C-u>FzfPreviewBufferTagsRpc<CR>
  "nnoremap <silent> [fzf-p]q     :<C-u>FzfPreviewQuickFixRpc<CR>
  "nnoremap <silent> [fzf-p]l     :<C-u>FzfPreviewLocationListRpc<CR>

      let profile = SpaceVim#mapping#search#getprofile('rg')
    let default_opt = profile.default_opts + ['--no-ignore-vcs']
    call SpaceVim#mapping#search#profile({'rg' : {'default_opts' : default_opt}})


    " fzf colorschemes
    call SpaceVim#custom#SPC('nmap', [';'], ':CocList commands', 'coc-commands', 1)
    " fzf.vim
    " f
    call SpaceVim#custom#SPC('nmap', ['f', 'a'], ':FzfPreviewGitActionsRpc', 'git-actions', 1)
    call SpaceVim#custom#SPC('nmap', ['f', 'f'], ':FzfFiles', 'project-files', 1)
    call SpaceVim#custom#SPC('nmap', ['f', 'g'], ':FzfPreviewGitFilesRpc', 'project-files', 1)
    call SpaceVim#custom#SPC('nmap', ['f', 'l'], ':FzfPreviewLinesRpc', 'buffer-lines', 1)
    call SpaceVim#custom#SPC('nmap', ['f', 'm'], ':FzfMessages', 'editor-logs', 1)
    call SpaceVim#custom#SPC('nmap', ['p', 'b'], ':FzfBuffers', 'list-buffers', 1)

    " coc diagnostics
    call SpaceVim#custom#SPC('nmap', ['e', 'l'], ':CocDiagnostics', 'list-errors', 1)
    call SpaceVim#custom#SPC('nmap', ['e', 'n'], '<Plug>(coc-diagnostic-next)', 'next-error', 0)
    call SpaceVim#custom#SPC('nmap', ['e', 'p'], '<Plug>(coc-diagnostic-prev)', 'prev-error', 0)

    " coc key bindings
    call SpaceVim#custom#SPC('nmap', ['m', 'r'], '<Plug>(coc-rename)', 'coc-rename', 0)
    call SpaceVim#custom#SPC('nmap', ['m', 'a'], '<Plug>(coc-codeaction-selected)', 'coc-action', 0)
    call SpaceVim#custom#SPC('xmap', ['m', 'a'], '<Plug>(coc-codeaction-selected)', 'coc-action', 0)
    call SpaceVim#custom#SPC('nmap', ['m', 'c'], '<Plug>(code-codeaction)', 'coc-actions', 0)
    call SpaceVim#custom#SPC('nmap', ['m', 'f'], '<Plug>(code-fix-current)', 'coc-fix-current', 0)

    " spacevim keybindings for config
    call SpaceVim#custom#SPCGroupName('u', '+Spacevim/Terms')
    call SpaceVim#custom#SPC('nnoremap', ['u', 'd'], ':call coc#util#install()', 'call-coc-util-install', 1)
    call SpaceVim#custom#SPC('nnoremap', ['u', 'u'], ':SPUpdate', 'update-spacevim', 1)
    call SpaceVim#custom#SPC('nnoremap', ['u', 'e'], ':e ~/.config/SpaceVim.d/autoload/myspacevim.vim', 'edit-spacevim-config', 1)
    call SpaceVim#custom#SPC('nnoremap', ['u', 'i'], ':SPConfig -l', 'edit-init.toml', 1)
    call SpaceVim#custom#SPC('nnoremap', ['u', 'r'], ':source ~/.config/SpaceVim.d/init.toml', 'source', 1)
    call SpaceVim#custom#SPC('nnoremap', ['u', 'l'], ':SPRuntimeLog ', 'log', 1)

  " FZF
  " This is the default extra key bindings
  let g:fzf_action = {
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit' }
  
  " Enable per-command history.
  " CTRL-N and CTRL-P will be automatically bound to next-history and
  " previous-history instead of down and up. If you don't like the change,
  " explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
  let g:fzf_history_dir = '~/.local/share/fzf-history'
  
  map <C-f> :Files<CR>
  map <leader>b :Buffers<CR>
  nnoremap <leader>g :Rg<CR>
  nnoremap <leader>t :Tags<CR>
  nnoremap <leader>m :Marks<CR>
  
  let g:fzf_tags_vcommand = 'ctags -R'
  " Border color
  let g:fzf_layout = {'up':'~90%', 'window': { 'width': 0.8, 'height': 0.8,'yoffset':0.5,'xoffset': 0.5, 'highlight': 'Todo', 'border': 'sharp' } }
  
  let $FZF_DEFAULT_OPTS = '--layout=reverse --info=inline'
  let $FZF_DEFAULT_COMMAND="rg --files --hidden"
  
  
  " Customize fzf colors to match your color scheme
  let g:fzf_colors =
  \ { 'fg':      ['fg', 'Normal'],
    \ 'bg':      ['bg', 'Normal'],
    \ 'hl':      ['fg', 'Comment'],
    \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
    \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
    \ 'hl+':     ['fg', 'Statement'],
    \ 'info':    ['fg', 'PreProc'],
    \ 'border':  ['fg', 'Ignore'],
    \ 'prompt':  ['fg', 'Conditional'],
    \ 'pointer': ['fg', 'Exception'],
    \ 'marker':  ['fg', 'Keyword'],
    \ 'spinner': ['fg', 'Label'],
    \ 'header':  ['fg', 'Comment'] }
  
  "Get Files
  command! -bang -nargs=? -complete=dir Files
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)
  
  
  " Get text in files with Rg
  #command! -bang -nargs=* Rg
  #  \ call fzf#vim#grep(
  #  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  #  \   fzf#vim#with_preview(), <bang>0)
  command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
    \   fzf#vim#with_preview(), <bang>0)

  " Ripgrep advanced
  #function! RipgrepFzf(query, fullscreen)
  #  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  #  let initial_command = printf(command_fmt, shellescape(a:query))
  #  let reload_command = printf(command_fmt, '{q}')
  #  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  #  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
  #endfunction
  
  command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
  
  " Git grep
  # command! -bang -nargs=* GGrep
  #   \ call fzf#vim#grep(
  #   \   'git grep --line-number '.shellescape(<q-args>), 0,
  #   \   fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

  "'liuchengxu/vista.vim'
  function! NearestMethodOrFunction() abort
    return get(b:, 'vista_nearest_method_or_function', '')
  endfunction

  set statusline+=%{NearestMethodOrFunction()}

  " By default vista.vim never run if you don't call it explicitly.
  "
  " If you want to show the nearest function in your statusline automatically,
  " you can add the following line to your vimrc
  autocmd VimEnter * call vista#RunForNearestMethodOrFunction()
endfunction

function! myspacevim#after() abort
  iunmap jk
endfunction
