" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2017-04-04
" @Revision:    58


let s:prototype = {}


function! s:prototype.CleanCFile(cfile) abort dict "{{{3
    let cfile = self.Viki_Super_CleanCFile(a:cfile)
    let cfile = substitute(cfile, '\]\[.\{-}\].\?\]$', ']]', 'g')
    let cfile = substitute(cfile, '\(^\[\[\|\].\?\]\+$\)', '', 'g')
    return cfile
endf


function! s:prototype.ExpandCFile() abort dict "{{{3
    let link = matchstr(getline('.'), '\[\[\zs[^]]\{-}\%'. col('.') .'c[^]]*\ze\]')
    Tlibtrace 'autolinker', 'viki.ExpandCFile', link
    if !empty(link)
        let iv = matchstr(link, '^[A-Z0-9_]\+\ze::')
        Tlibtrace 'autolinker', 'viki.ExpandCFile', iv
        if !empty(iv)
            let prefix = exists('g:vikiInter'. iv) ? g:vikiInter{iv} : ''
            if prefix !~# '[\/]$'
                let prefix .= '/'
            endif
            let link = prefix . substitute(link, '^[^:]\+::', '', '')
            if exists('g:vikiInter'. iv .'_suffix')
                let link = s:MaybeAppendSuffix(link, g:vikiInter{iv}_suffix)
            endif
        endif
        for l:sfx in ['e', 'b:viki_name_suffix', 'g:viki_name_suffix', 'b:vikiNameSuffix', 'g:vikiNameSuffix']
            if l:sfx ==# 'e'
                let l:suffix = '.'. expand('%:e')
            elseif exists(l:sfx)
                let l:suffix = eval(l:sfx)
            else
                continue
            endif
            Tlibtrace 'autolinker', 'viki.ExpandCFile', link, l:suffix
            let link1 = self.CheckCFile(s:MaybeAppendSuffix(link, l:suffix))
            Tlibtrace 'autolinker', 'viki.ExpandCFile', link1, tlib#file#Filereadable(link1)
            if tlib#file#Filereadable(link1)
                let link = link1
                break
            endif
        endfor
        Tlibtrace 'autolinker', 'viki.ExpandCFile', link
    else
        let link = expand('<cfile>')
        Tlibtrace 'autolinker', 'viki.ExpandCFile', 'cfile', link
    endif
    return link
endf


function! s:MaybeAppendSuffix(text, suffix) abort "{{{3
    let l:tsuf = a:text[-len(a:suffix) : -1]
    Tlibtrace 'autolinker', a:text, a:suffix, l:tsuf
    if l:tsuf ==# a:suffix
        return a:text
    else
        return a:text . a:suffix
    endif
endf


function! s:prototype.IsInternalLink(cfile) abort dict "{{{3
    return a:cfile =~ '^#\S\+$'
endf


function! autolinker#ft_viki#GetInstance(prototype) abort "{{{3
    let a:prototype.Viki_Super_CleanCFile = a:prototype.CleanCFile
    return extend(a:prototype, s:prototype)
endf

