" vim:set foldmethod=marker:
scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

if exists("g:loaded_mysession_plugin")
    finish
endif
let g:loaded_mysession_plugin = 1

let s:true = 1
let s:false = 0

" Init
" let revimses#session_loaded = s:false
" let revimses#session_loaded = s:true

if !exists("revimses#myvimsessions_folder")
    let revimses#myvimsessions_folder = "~/.vimsessions"
endif

let revimses#save_session_flag = s:true " TabMerge, ClearSession時用のフラグ
let revimses#save_window_file = expand(revimses#myvimsessions_folder) . '/.vimwinpos'

if isdirectory(expand(revimses#myvimsessions_folder)) != 1
    call mkdir(expand(revimses#myvimsessions_folder),"p")
endif

if has("gui_running")
    if filereadable(expand(revimses#save_window_file))
        execute "source" revimses#save_window_file
    endif
endif

augroup MYSESSIONVIM
    autocmd!
    " nestedしないとSyntaxなどの設定が繁栄されない（BufReadとかがたぶん呼ばれない）
    autocmd VimEnter * nested if @% == '' && revimses#getbufbyte() == 0 | call revimses#load_session("default.vim",s:false) | endif
    autocmd VimLeavePre * call revimses#save_window(revimses#save_window_file)
    autocmd VimLeavePre * if revimses#save_session_flag == s:true | call revimses#save_session("default.vim",s:true) | endif

    " いつか実装したいTabマージ機構
    " autocmd VimEnter * nested if @% != '' || revimses#getbufbyte() != 0 | call revimses#tab_merge()
    " バックアップ用
    " autocmd CursorHold * if revimses#save_session_flag == s:true | call revimses#save_session("default.vim",s:false) | endif
    " autocmd CursorHoldI * if revimses#save_session_flag == s:true | call revimses#save_session("default.vim",s:false) | endif

augroup END

" command! TabMerge call revimses#tab_merge()
command! SessionClearAndQuit call revimses#clear_session()
command! SessionLoadLast call revimses#load_session("default.vim",s:true)
command! -nargs=1 -complete=customlist,revimses#customlist SessionLoadSaved call revimses#load_session(<q-args>,s:true)
command! -nargs=1 SessionSave call revimses#save_session(<q-args>,s:true)
command! SessionLoadClearedSession call revimses#load_session('.backup.vim',s:true)

let &cpo = s:save_cpo
unlet s:save_cpo
