" @Author:      Thomas Link (micathom AT gmail.com)
" @GIT:         http://github.com/tomtom/autolinker_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2021-03-28.
" @Revision:    127
" GetLatestVimScripts: 5253 0 :AutoInstall: autolinker.vim
" Automatic hyperlinks for any filetype

if &cp || exists('loaded_autolinker')
    finish
endif
let loaded_autolinker = 3

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:autolinker_filetypes')
    let g:autolinker_filetypes = ['text', 'txt', 'todo', 'ttodo', 'todotxt', 'md', 'markdown', 'markdown.pandoc', 'pandoc', 'rmd', 'rmarkdown', 'tex', 'latex', 'bib']   "{{{2
endif
if exists('g:autolinker_filetypes_user')
    let g:autolinker_filetypes += g:autolinker_filetypes_user
endif


if !exists('g:autolinker_patterns')
    let g:autolinker_patterns = ['*.txt', '*.TXT', '*.md', '*.markdown']   "{{{2
endif
if exists('g:autolinker_patterns_user')
    let g:autolinker_patterns += g:autolinker_patterns_user
endif


if !exists('g:autolinker_exclude_filetypes')
    " Don't enable autolinker for filetypes matching this |regexp| 
    " even when the filename matches |g:autolinker_patterns|.
    let g:autolinker_exclude_filetypes_rx = ''   "{{{2
endif


if !exists('g:autolinker_install_syntax_events')
    " :nodoc:
    let g:autolinker_install_syntax_events = 'BufEnter,BufWinEnter,CursorHold,CursorHoldI,CursorMoved,CursorMovedI'   "{{{2
endif



" :nodoc:
let g:autolinker_glob_cache = {}

" :nodoc:
command! -bar Alcachereset let g:autolinker_glob_cache = {}


" Enable the autolinker plugin for the current buffer.
command! -bar Albuffer call autolinker#EnableBuffer()


" " Edit/create a file in path.
command! -bar -nargs=1 -complete=customlist,autolinker#CompleteFilename Aledit call autolinker#Edit(<q-args>)


" Grep all files with prefixes defined in |g:autolinker#cfile_gsub|.
" This requires the trag_vim plugin to be installed.
" See also |:Tragsearch|.
command! -bar -bang -nargs=+ Algrep if exists(':Trag') == 2 | Trag<bang> --filenames --file_sources=*autolinker#FileSources <args> | else | echom ':Algrep requires the trag_vim plugin to be installed!' | endif


" Find a file via |:Tragfiles|.
command! -bar -bang -nargs=* -complete=customlist,trag#CComplete Alfind if exists(':Tragfiles') == 2 | Tragfiles<bang> --grep_filenames --no-grep_text --file_sources=*autolinker#FileSources <args> | else | echom ':Alfind requires the trag_vim plugin to be installed!' | endif


augroup AutoLinker
    autocmd! AutoLinker
    autocmd FocusLost * Alcachereset
    autocmd BufWritePre,FileWritePre * if index(g:autolinker_filetypes, &ft, 0, 0) != -1 && !filereadable(expand("<afile>")) | Alcachereset | endif
    autocmd FileType * if index(g:autolinker_filetypes, &ft, 0, 0) != -1 | exec 'autocmd AutoLinker' g:autolinker_install_syntax_events '<buffer> call autolinker#EnableFiletype()' | endif
    for s:item in g:autolinker_patterns
        exec 'autocmd BufWinEnter' s:item 'if empty(g:autolinker_exclude_filetypes_rx) || &filetype !~? g:autolinker_exclude_filetypes_rx | call autolinker#Ensure() | endif'
        exec 'autocmd BufWritePre,FileWritePre' s:item 'if (empty(g:autolinker_exclude_filetypes_rx) || &filetype !~? g:autolinker_exclude_filetypes_rx) && !filereadable(expand("<afile>")) | Alcachereset | endif'
    endfor
    unlet! s:item
augroup end

" Check the current buffer too in case the plugin gets loaded after 
" startup.
if index(g:autolinker_filetypes, &filetype) != -1
    Albuffer
endif


let &cpo = s:save_cpo
unlet s:save_cpo
