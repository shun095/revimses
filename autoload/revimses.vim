scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim

let s:true = 1
let s:false = 0

function! revimses#getbufbyte() abort
" check buffer size
	let byte = line2byte(line('$') + 1)
	if byte == -1
		return 0
	else
		return byte - 1
	endif
endfunction

function! revimses#load_session(session_name,notify_flag) abort
	" let revimses#session_loaded = s:true
	let l:fullpath = fnamemodify(expand(g:revimses#session_dir),'p') . '/' . a:session_name
	if filereadable(expand(l:fullpath))
		execute 'source' l:fullpath
		if a:notify_flag == s:true
			echom "Session-file: '" . l:fullpath . "' was loaded."
		endif
		if a:session_name ==# '.default.vim'
			call rename(l:fullpath, fnamemodify(expand(g:revimses#session_dir),'p') . '/' . '.current.vim')
		endif
	else
		if a:notify_flag == s:true
			echom "Session-file: '" . l:fullpath . "' can't be found."
		endif
	endif
endfunction

function! revimses#save_session(session_name,notify_flag) abort
	" if g:revimses#session_loaded == s:true
	let l:saved_sessionopts = &sessionoptions
	let &sessionoptions = g:revimses#sessionoptions
	let session_dir = fnamemodify(expand(g:revimses#session_dir),'p')
	try
		execute  'mksession! '  session_dir . '/' . a:session_name
		if a:notify_flag == s:true
			echom "Session saved to '" . session_dir . '/' . a:session_name . "'."
		endif
		if a:session_name ==# '.default.vim'
			call delete(session_dir . '/' . '.current.vim')
		endif
	catch
		echoerr v:exception
	finally
		let &sessionoptions = l:saved_sessionopts
	endtry
endfunction

function! revimses#delete_session(session_name,notify_flag) abort
	let l:delete_flag = confirm('Delete session file? :' . a:session_name, "&Yes\n&No",2)
	if l:delete_flag == 1
		call delete(expand(g:revimses#session_dir . '/' . a:session_name))
		echom "Session-file: '" . expand(g:revimses#session_dir . '/' . a:session_name) . "' was deleted."
	endif
endfunction

function! revimses#save_window(save_window_file) abort
  " let l:saved_sessionopts = &sessionoptions
  " set sessionoptions=winpos,winsize,resize
  " " let session_dir = fnamemodify(expand(g:revimses#session_dir),'p')
  " let window_file = fnamemodify(expand(a:save_window_file),'p')
  " " execute 'mksession! ' session_dir . '/' . a:save_window_file
  " execute 'mksession! ' .  window_file
    let l:window_maximaize = ''
    if has('win32')
        if libcallnr('User32.dll', 'IsZoomed', v:windowid)
            let l:window_maximaize = 'au GUIEnter * simalt ~x'
        endif
    endif
    let options = [
                \ 'set lines=' . &lines,
                \ 'set columns=' . &columns,
                \ 'winpos ' . getwinposx() . ' ' . getwinposy(),
                \ l:window_maximaize
                \ ]
    call writefile(options, a:save_window_file)
  " let &sessionoptions = l:saved_sessionopts
endfunction

function! revimses#clear_session() abort
	call g:revimses#save_session('.default.vim',s:false)
	call rename(expand(g:revimses#session_dir) . '/.default.vim',
				\ expand(g:revimses#session_dir) . '/.backup.vim')
	let g:revimses#save_session_flag = s:false
	quitall
endfunction

function! revimses#customlist(ArgLead, CmdLine, CursorPos) abort
	let l:save_cd = getcwd()
	exe 'cd ' . expand(g:revimses#session_dir)
	let l:filelist = glob(a:ArgLead . '*',1,1)
	exe 'cd ' . expand(l:save_cd)
	return l:filelist
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
