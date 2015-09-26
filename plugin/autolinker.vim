" @Author:      Thomas Link (micathom AT gmail.com)
" @GIT:         http://github.com/tomtom/autolinker_vim/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-09-26.
" @Revision:    19
" GetLatestVimScripts: 0 0 :AutoInstall: autolinker.vim
" Automatic hyperlinks for any filetype

if &cp || exists("loaded_autolinker")
    finish
endif
let loaded_autolinker = 1

let s:save_cpo = &cpo
set cpo&vim


if !exists('g:autolinker_filetypes')
    let g:autolinker_filetypes = ['text', 'txt', 'viki', 'todo', 'todotxt', 'md', 'markdown', 'tex', 'latex', 'help']   "{{{2
endif


if !exists('g:autolinker_patterns')
    let g:autolinker_patterns = ['*.txt', '*.TXT', '*.md', '*.markdown']   "{{{2
endif


augroup AutoLinker
    augroup! AutoLinker
    for s:item in g:autolinker_filetypes
        exec 'autocmd FileType' s:item 'call autolinker#EnableBuffer()'
    endfor
    for s:item in g:autolinker_patterns
        exec 'autocmd BufWinEnter' s:item 'call autolinker#Ensure()'
    endfor
    unlet! s:item
augroup end


command! -bar Autolinkbuffer call autolinker#EnableBuffer()


let &cpo = s:save_cpo
unlet s:save_cpo
