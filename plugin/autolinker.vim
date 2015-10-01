" @Author:      Thomas Link (micathom AT gmail.com)
" @GIT:         http://github.com/tomtom/autolinker_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-10-01.
" @Revision:    58
" GetLatestVimScripts: 0 0 :AutoInstall: autolinker.vim
" Automatic hyperlinks for any filetype

if &cp || exists("loaded_autolinker")
    finish
endif
let loaded_autolinker = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:autolinker_filetypes')
    let g:autolinker_filetypes = ['text', 'txt', 'todo', 'todotxt', 'md', 'markdown', 'markdown.pandoc', 'tex', 'latex', 'help']   "{{{2
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


" :nodoc:
let g:autolinker_glob_cache = {}

" :nodoc:
command! -bar Alcachereset let g:autolinker_glob_cache = {}


augroup AutoLinker
    augroup! AutoLinker
    autocmd FocusLost * Alcachereset
    autocmd BufWritePre,FileWritePre * if index(g:autolinker_filetypes, &ft, 0, 0) != -1 && !filereadable(expand("<afile>")) | Alcachereset | endif
    autocmd BufWinEnter * if index(g:autolinker_filetypes, &ft, 0, 0) != -1 | call autolinker#Ensure() | endif
    for s:item in g:autolinker_patterns
        exec 'autocmd BufWinEnter' s:item 'call autolinker#Ensure()'
        exec 'autocmd BufWritePre,FileWritePre' s:item 'if !filereadable(expand("<afile>")) | Alcachereset | endif'
    endfor
    unlet! s:item
augroup end


" Enable the autolinker plugin for the current buffer.
command! -bar Albuffer call autolinker#EnableBuffer()


" Edit/create a file in path.
command! -bar -nargs=1 -complete=file_in_path Aledit call autolinker#Edit(<q-args>)


let &cpo = s:save_cpo
unlet s:save_cpo
