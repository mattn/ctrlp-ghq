if exists('g:loaded_ctrlp_ghq') && g:loaded_ctrlp_ghq
  finish
endif
let g:loaded_ctrlp_ghq = 1

let s:ghq_var = {
\  'init':   'ctrlp#ghq#init()',
\  'exit':   'ctrlp#ghq#exit()',
\  'accept': 'ctrlp#ghq#accept',
\  'lname':  'ghq',
\  'sname':  'ghq',
\  'type':   'path',
\  'sort':   0,
\  'nolim':  1,
\}

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:ghq_var)
else
  let g:ctrlp_ext_vars = [s:ghq_var]
endif

let s:ghq_command = get(g:, 'ctrlp_ghq_command', 'ghq')
let s:cache_enabled = get(g:, 'ctrlp_ghq_cache_enabled', 0)

let s:cache_dir = ctrlp#utils#cachedir() . ctrlp#utils#lash() . 'ghq'
let s:cache_file = s:cache_dir . ctrlp#utils#lash() . 'cache.txt'

function! ctrlp#ghq#init()
  nnoremap <buffer> <silent> <c-a> :call ctrlp#ghq#menu()<cr>
  if !s:cache_enabled
    return s:get_repos()
  endif

  nnoremap <buffer> <silent> <F5> :call ctrlp#ghq#reload()<cr>
  if empty(s:repos)
    call ctrlp#ghq#reload()
  endif
  return s:repos
endfunc

function! ctrlp#ghq#menu()
  let str = ctrlp#getcline()
  if !empty(str)
    call ctrlp#ghq#accept('m', str)
  endif
endfunction

function! ctrlp#ghq#accept(mode, str)
  call ctrlp#exit()
  let path = get(map(filter(split(globpath(s:root, a:str), '\n'), 'isdirectory(v:val)'), 'fnamemodify(v:val, "p")'), 0, '')
  let action = get(g:, 'ctrlp_ghq_default_action', 'lcd')

  let actions = get(g:, 'ctrlp_ghq_actions', [])
  if a:mode == 'm' && !empty(actions) && type(actions) == 3
    let choice = confirm("Action?", join(map(copy(actions), 'v:val["label"]'), "\n"))
    redraw
    if choice == 0
      return
    endif
    let act = actions[choice-1]
    let action = get(act, 'action', action)
    let path = get(act, 'path', 1) ? path : a:str
  endif
  exe action path
  doautoall BufEnter
endfunction

function! ctrlp#ghq#exit()
  if s:cache_enabled
    let lines = [printf('{"root" : %s}',string(s:root))] + s:repos
    call ctrlp#utils#writecache(lines, s:cache_dir, s:cache_file)
  endif
endfunction

function! ctrlp#ghq#reload()
  if !s:check_cache_date()
    let s:root = s:get_root()
  endif
  let s:repos = s:get_repos()
  call ctrlp#setlines()
endfunction

function! s:init()
  let s:root = ''
  let s:repos = []

  if s:cache_enabled && s:check_cache_date()
    let lines = ctrlp#utils#readfile(s:cache_file)
    let s:root = s:validate(lines)
    if !empty(s:root)
      let s:repos = lines[1:]
    endif
  endif

  if empty(s:root)
    let s:root = s:get_root()
  endif
endfunction

function! s:check_cache_date()
  return filereadable(s:cache_file) &&
        \ getftime(s:cache_file) >= getftime(expand('~/.gitconfig'))
endfunction

function! s:validate(lines)
  if !len(a:lines)
    return ''
  endif
  try
    let header = eval(a:lines[0])
    if has_key(header, 'root') &&
          \ type(header.root) == type('') &&
          \ len(filter(split(header.root, ','), '!isdirectory(v:val)')) == 0
      return header.root
    endif
  catch /^Vim\%((\a\+)\)\=:/	" Catch any exceptions or interruptions
    return ''
  endtry
endfunction

function! s:get_root()
  let root = join(split(system('git config --path --get-all ghq.root'), "\n"), ',')
  if empty(root)
    let root = expand('~/.ghq')
  endif
  return root
endfunction

function! s:get_repos()
  return split(system(printf('%s list', s:ghq_command)), '\n')
endfunction

call s:init()

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#ghq#id()
  return s:id
endfunction

" vim:fen:fdl=0:ts=2:sw=2:sts=2
