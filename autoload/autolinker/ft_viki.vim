" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-09-24
" @Revision:    5


let s:prototype = {}


function! s:prototype.CleanCFile(cfile) abort dict "{{{3
    let cfile = substitute(a:cfile, '\(^\[\[\|\].\?\]\+$\)', '', 'g')
    return cfile
endf


function! autolinker#ft_viki#GetInstance() abort "{{{3
    return s:prototype
endf

