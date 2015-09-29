" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-09-28
" @Revision:    18


let s:prototype = {}


function! s:prototype.CleanCFile(cfile) abort dict "{{{3
    let cfile = self.Viki_Super_CleanCFile(a:cfile)
    let cfile = substitute(cfile, '\]\[.\{-}\].\?\]$', ']]', 'g')
    let cfile = substitute(cfile, '\(^\[\[\|\].\?\]\+$\)', '', 'g')
    return cfile
endf


function! autolinker#ft_viki#GetInstance(prototype) abort "{{{3
    let a:prototype.Viki_Super_CleanCFile = a:prototype.CleanCFile
    return extend(a:prototype, s:prototype)
endf

