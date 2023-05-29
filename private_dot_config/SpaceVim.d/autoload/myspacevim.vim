function! myspacevim#before() abort

  call SpaceVim#logger#info("bootstrap_after called")     " log bootstrap_after call

  " allow jk to exit into normal mode in terminal buffer
  tnoremap jk <Esc>

  " spacevim keybindings for config
  call SpaceVim#custom#SPCGroupName('u', '+Spacevim/Terms')
  call SpaceVim#custom#SPC('nnoremap', ['u', 'u'], ':SPUpdate', 'update-spacevim', 1)
  call SpaceVim#custom#SPC('nnoremap', ['u', 'e'], ':e ~/.config/SpaceVim.d/autoload/myspacevim.vim', 'edit-spacevim-config', 1)
  call SpaceVim#custom#SPC('nnoremap', ['u', 'i'], ':SPConfig -l', 'edit-init.toml', 1)
  call SpaceVim#custom#SPC('nnoremap', ['u', 'r'], ':source ~/.config/SpaceVim.d/init.toml', 'source', 1)
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

  " sessions directory
  let g:startify_session_dir = $HOME .  '/.data/' . ( has('nvim') ? 'nvim' : 'vim' ) . '/session'

  " org-mode plugin configuration
  lua << EOF
  -- Load custom treesitter grammar for org filetype
  require('orgmode').setup_ts_grammar()
  
  -- Treesitter configuration
  require('nvim-treesitter.configs').setup {
    -- If TS highlights are not enabled at all, or disabled via `disable` prop,
    -- highlighting will fallback to default Vim syntax highlighting
    highlight = {
      enable = true,
      -- Required for spellcheck, some LaTex highlights and
      -- code block highlights that do not have ts grammar
      additional_vim_regex_highlighting = {'org'},
    },
    ensure_installed = {'org'}, -- Or run :TSUpdate org
  }
  
  require('orgmode').setup({
    org_agenda_files = {'~/org/*'},
    org_default_notes_file = '~/org/tasks.org',
  })
EOF

endfunction
