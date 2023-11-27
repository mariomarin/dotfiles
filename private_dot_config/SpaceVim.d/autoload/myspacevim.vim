function! myspacevim#before() abort

  call SpaceVim#logger#info("bootstrap_after called")     " log bootstrap_after call

  " https://www.chezmoi.io/user-guide/tools/editor/#configure-vim-to-run-chezmoi-apply-whenever-you-save-a-dotfile
  autocmd BufWritePost /tmp/*chezmoi-edit* ! chezmoi apply --force

  " Neoformat settings
  let g:neoformat_enabled_yaml = [ 'prettier' ]
  let g:neoformat_enabled_yaml = ["prettier"]
  let g:neoformat_yaml_prettier = {
                \      'exe': "prettier",
                \      'args': ["--stdin-filepath", '"%:p"', "--tab-width=2"],
                \      'stdin': 1,
                \  }

  let g:neoformat_enabled_sh = ['shfmt']
  let g:neoformat_sh_shfmt = {
      \ 'exe': 'shfmt',
      \ 'args': ['--language-dialect', 'bash', '--indent', '4', '--space-redirects', '--binary-next-line', '--keep-padding'],
      \ 'stdin': 1,
      \ }
      let g:neoformat_enabled_yaml = ["prettier"]

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

  " Setup a yamlls plugin
  " require'lspconfig'.yamlls.setup{
    " settings = {
      " json = {
          " schemas = {
              " ["https://raw.githubusercontent.com/quantumblacklabs/kedro/develop/static/jsonschema/kedro-catalog-0.17.json"]= "conf/**/*catalog*",
              " ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              " ["https://github.com/ansible/schemas/blob/main/f/ansible.json"] = "*.yaml,*.yml"
          " }
      " },
      " yaml = {
          " keyOrdering = false
      " },
    " }
  " }


endfunction
