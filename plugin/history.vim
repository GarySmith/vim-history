" vim-history - Record and view history of every file write
"
" Author:   Gary Smith <github.com/GarySmith>
" Version:  0.1
"

if exists('g:loaded_history')
  finish
endif
let g:loaded_history = 1

let s:save_cpo = &cpo
set cpo&vim

let s:debug = 0
if s:debug == 1
  set cmdheight=4
endif

if !executable('git')
  echohl ErrorMsg | echomsg 'vim-history requires the ''git'' command' | echohl None
  finish
endif

" history_dir should be relative to the file being edited
if !exists('g:history_dir')
  let g:history_dir = '.local_history'
endif

function! s:debug(str) abort
  if s:debug == 1
    echohl WarningMsg
    echomsg a:str
    echohl None
  endif
endfunction

" Perform git operations with git_dir set to the configured directory
function! s:git_cmd(...) abort
  let args = ['git', '--git-dir=' . fnameescape(g:history_dir) ] + a:000
  let cmd = join(args, ' ')

  return system(cmd)
endfunction

function! s:repo_exists() abort
  let dir = s:git_cmd('rev-parse','--git-dir')
  return v:shell_error == 0
endfunction

function! s:create_repo() abort

  if s:repo_exists()
    return
  endif

  call s:debug("Creating new repo")

  " Create the repo and configure it to be non-bare
  call s:git_cmd('init')
  call s:git_cmd('config', '--local', 'core.bare','false')
  call s:git_cmd('config', '--local', 'core.logallrefupdates','true')

  " Exclude the repo name from itself, when the name is other than .git
  let repo_dirname = fnamemodify(g:history_dir, ':t')
  if repo_dirname !=# '.git'
    let repo_fullname = fnamemodify(g:history_dir, ':p')
    exe 'silent !echo ' . repo_dirname . ' >> ' . repo_fullname . 'info/exclude'
  endif

  " Set a local user and email if neither is configured globally
  let user = s:git_cmd('config', 'user.name')
  if strlen(user) == 0
    let user = $USER
    if strlen(user) == 0
      let user = 'nobody'
    endif

    call s:git_cmd('config', '--local', 'user.name', user)
  endif

  let email = s:git_cmd('config', 'user.email')
  if strlen(email) == 0
    let email = join([user, "nowhere"], "@")
    call s:git_cmd('config', '--local', 'user.email', email)
  endif

endfunction

function! s:commit_file(file) abort

  if len(a:file) == 0
    return
  endif

  let fname = fnameescape(a:file)
  call s:create_repo()

  call s:git_cmd('add', fname)

  call s:git_cmd('diff-index', '--quiet', '--cached', 'HEAD', '--', fname)
  if v:shell_error == 0
    call s:debug("No changes to commit")
    return
  endif

  let shortname = fnamemodify(a:file, ":p:t")

  call s:git_cmd('commit', '--no-verify', '-m', shortname, '--', fname)
  if v:shell_error != 0
    call s:debug("Failed to commit " . fname)
  else
    call s:debug("Saved into history")
  endif
endfunction

command! -nargs=0 HistoryCreateRepo execute s:create_repo()
command! -nargs=0 HistoryCommitFile execute s:commit_file(expand('%:p'))

" Command for writing to history in a BufWritePost autocmd
command! -nargs=0 HistorySave execute s:commit_file(expand("<afile>:p"))

let &cpo = s:save_cpo
