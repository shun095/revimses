scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if exists('g:loaded_revimses')
  finish
endif
let g:loaded_revimses = 1

let s:true = 1
let s:false = 0

" Option Vals
if !exists('revimses#session_dir')
  let revimses#session_dir = '~/.vimsessions'
endif

if !exists('revimses#sessionoptions')
  let revimses#sessionoptions = 'folds,help,tabpages'
endif

" saved_sessionoptsを決めなかった場合の挙動をどうしよう
" if &sessionoptions == "blank,buffers,curdir,folds,help,options,tabpages,winsize"
" 	let revimses#sessionoptions = 'folds,help,tabpages'
" endif
" 
let s:user_ses_dir = fnamemodify(expand(revimses#session_dir), 'p')
let s:autosave_ses_dir = s:user_ses_dir . '/.autosave'

let revimses#save_session_flag = s:true " TabMerge, ClearSession時用のフラグ
let revimses#save_window_file = s:user_ses_dir . '/.vimwinpos'

if !isdirectory(s:user_ses_dir)
  call mkdir(s:user_ses_dir,'p')
endif

if !isdirectory(s:autosave_ses_dir)
  call mkdir(s:autosave_ses_dir ,'p')
endif

if has('gui_running')
  if filereadable(expand(revimses#save_window_file))
    execute 'source' revimses#save_window_file
  endif
endif

augroup Revimses
  autocmd!
  " nestedしないとSyntaxなどの設定が繁栄されない（BufReadとかがたぶん呼ばれない）
  autocmd VimEnter * nested if @% == '' && revimses#getbufbyte() == 0 | call revimses#load_session(".default.vim",s:false) | endif
  autocmd QuitPre * call revimses#save_window(revimses#save_window_file)
  autocmd QuitPre * if revimses#save_session_flag == s:true | call revimses#save_session(".default.vim",s:true) | endif
augroup END


command! RevimsesClearAndQuit call revimses#clear_session()
command! -nargs=1 -complete=customlist,revimses#customlist
      \ RevimsesLoadSaved call revimses#load_session(<q-args>,s:true)
command! -nargs=1 -complete=customlist,revimses#customlist
      \ RevimsesDeleteSaved call revimses#delete_session(<q-args>,s:true)
command! -nargs=1 RevimsesSave call revimses#save_session(<q-args>,s:true)

if has('job')
  fun! revimses#timer_callback(timer) abort
    " code
    call revimses#save_session('.current_bak.vim',s:true)
  endf

  call timer_start(300000, 'revimses#timer_callback', {'repeat' : -1})
endif

let &cpo = s:save_cpo
unlet s:save_cpo
