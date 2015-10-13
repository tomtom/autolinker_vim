" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-10-13
" @Revision:    40


let s:prototype = {}


function! s:prototype.CleanCFile(cfile) abort dict "{{{3
    let cfile = self.Markdown_Super_CleanCFile(a:cfile)
    let cfile = s:GetLinkMapLink(cfile)
    return cfile
endf


function! s:prototype.JumpInternalLink(cfile) abort dict "{{{3
    let rx = printf('\V\%(\^\s\*%s\>\|\<id\s\*=\s\*\["'']\?%s\>\)',
                \ tlib#rx#Escape(a:cfile, 'V'),
                \ tlib#rx#Escape(substitute(a:cfile, '^#', '', ''), 'V'))
    return search(rx, 'cw') > 0
endf


function! s:prototype.IsInternalLink(cfile) abort dict "{{{3
    return a:cfile =~ '^#\S\+$'
endf


function! s:GetLinkMapLink(cfile) abort "{{{3
    let lines = getline(line('.'), '$')
    let rx = printf('^\s\+\[%s\]:\s\+\zs\S\+', a:cfile)
    let lines = filter(lines, 'v:val =~ rx')
    if !empty(lines)
        return matchstr(lines[0], rx)
    else
        return a:cfile
    endif
endf


function! autolinker#ft_markdown#GetInstance(prototype) abort "{{{3
    let a:prototype.Markdown_Super_CleanCFile = a:prototype.CleanCFile
    return extend(a:prototype, s:prototype)
endf

