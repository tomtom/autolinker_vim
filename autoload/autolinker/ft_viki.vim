" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2017-03-30
" @Revision:    34


let s:prototype = {}


function! s:prototype.CleanCFile(cfile) abort dict "{{{3
    let cfile = self.Viki_Super_CleanCFile(a:cfile)
    let cfile = substitute(cfile, '\]\[.\{-}\].\?\]$', ']]', 'g')
    let cfile = substitute(cfile, '\(^\[\[\|\].\?\]\+$\)', '', 'g')
    return cfile
endf


function! s:prototype.ExpandCFile() abort dict "{{{3
    let link = matchstr(getline('.'), '\[\[\zs[^]]\{-}\%'. col('.') .'c[^]]*\ze\]')
    Tlibtrace 'autolinker', 'ExpandCFile', link
    if !empty(link)
        let iv = matchstr(link, '^[A-Z0-9_]\+\ze::')
        Tlibtrace 'autolinker', 'ExpandCFile', iv
        if !empty(iv)
            let prefix = exists('g:vikiInter'. iv) ? g:vikiInter{iv} : ''
            if prefix !~# '[\/]$'
                let prefix .= '/'
            endif
            let suffix = exists('g:vikiInter'. iv .'_suffix') ? g:vikiInter{iv}_suffix : ''
            Tlibtrace 'autolinker', 'ExpandCFile', prefix, suffix
            let link = prefix . substitute(link, '^[^:]\+::', '', '') . suffix
            Tlibtrace 'autolinker', 'ExpandCFile', link
        endif
    else
        let link = expand('<cfile>')
        Tlibtrace 'autolinker', 'ExpandCFile', 'cfile', link
    endif
    return link
endf


function! s:prototype.IsInternalLink(cfile) abort dict "{{{3
    return a:cfile =~ '^#\S\+$'
endf


function! autolinker#ft_viki#GetInstance(prototype) abort "{{{3
    let a:prototype.Viki_Super_CleanCFile = a:prototype.CleanCFile
    return extend(a:prototype, s:prototype)
endf

