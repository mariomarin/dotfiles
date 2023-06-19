function! myspacevim#before() abort

  call SpaceVim#logger#info("bootstrap_after called")     " log bootstrap_after call

  " allow jk to exit into normal mode in terminal buffer
  tnoremap kj <Esc>

  " \ is too far
  let mapleader = ","

  " spacevim keybindings for config
  call SpaceVim#custom#SPCGroupName('u', '+Spacevim/Terms')
  call SpaceVim#custom#SPC('nnoremap', ['u', 'u'], ':SPUpdate', 'update-spacevim', 1)
  call SpaceVim#custom#SPC('nnoremap', ['u', 'e'], ':e ~/.config/SpaceVim.d/autoload/myspacevim.vim', 'edit-spacevim-config', 1)
  call SpaceVim#custom#SPC('nnoremap', ['u', 'i'], ':SPConfig -l', 'edit-init.toml', 1)
  call SpaceVim#custom#SPC('nnoremap', ['u', 'l'], ':SPRuntimeLog ', 'log', 1)

  " https://www.chezmoi.io/user-guide/tools/editor/#configure-vim-to-run-chezmoi-apply-whenever-you-save-a-dotfile
  autocmd BufWritePost /tmp/*chezmoi-edit* ! chezmoi apply --force

  " Neoformat settings
  let g:neoformat_enabled_yaml = [ 'prettier' ]

  " Detect Cargo tasks
  function! s:cargo_task() abort
      if filereadable('Cargo.toml')
          let commands = ['build', 'run', 'test']
          let conf = {}
          for cmd in commands
              call extend(conf, {
                          \ cmd : {
                          \ 'command': 'cargo',
                          \ 'args' : [cmd],
                          \ 'isDetected' : 1,
                          \ 'detectedName' : 'cargo:'
                          \ }
                          \ })
          endfor
          return conf
      else
          return {}
      endif
  endfunction
  call SpaceVim#plugins#tasks#reg_provider(funcref('s:cargo_task'))
endfunction

function! myspacevim#after() abort

  " nvim-orgmode configuration
  lua require('init')

endfunction
