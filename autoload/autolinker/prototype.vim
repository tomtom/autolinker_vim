" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-09-28
" @Revision:    2


let s:prototype = {'fallback': g:autolinker#fallback
            \ , 'use_highlight': g:autolinker#use_highlight
            \ , 'cfile_gsub': g:autolinker#cfile_gsub
            \ }


function! s:prototype.Dispatch(method, default, ...) abort dict "{{{3
    " TLogVAR a:method, has_key(self, a:method)
    if has_key(self, a:method)
        let rv = call(self[a:method], a:000, self)
    else
        let fn = 'autolinker#'. a:method
        " TLogVAR fn, exists('*'. fn), a:000
        if exists('*'. fn)
            let rv = call(fn, [self] + a:000)
        else
            let rv = a:default
        endif
    endif
    " TLogVAR rv
    return rv
endf


function! s:prototype.BaseNameLinks() dict abort "{{{3
    let files = s:Globpath(self.Dirname(), get(self, 'pattern', '*'))
    " TLogVAR self.Dirname(), files
    let defs = {}
    let rootname = self.Rootname()
    for filename in files
        let rname = fnamemodify(filename, ':t:r')
        " TLogVAR rootname, rname
        if !empty(rname) && rootname != rname
            let vrx = '\V\<'. escape(rname, '\') .'\>'
            let defs[rname] = {'rx': vrx, 'filename': filename}
        endif
    endfor
    return defs
endf


function! s:prototype.Dirname() abort dict "{{{3
    return expand('%:p:h')
endf


function! s:prototype.Rootname() abort dict "{{{3
    return expand('%:t:r')
endf


function! s:prototype.Highlight() abort dict "{{{3
    if self.use_highlight
        silent! syn clear AutoHyperlink
        let rx = join(map(values(self.defs), 'v:val.rx'), '\|')
        if !empty(rx)
            exec 'syn match AutoHyperlink /'. escape(rx, '/') .'/'
            let col = &background == 'dark' ? 'Cyan' : 'DarkBlue'
            exec 'hi AutoHyperlink term=underline cterm=underline gui=underline ctermfg='. col 'guifg='. col
        endif
    endif
endf


function! s:prototype.Jump_system(mode, cword, cfile) abort dict "{{{3
    " TLogVAR a:mode, a:cword, a:cfile
    if a:cfile =~ g:autolinker#system_rx
        let cmd = printf(g:autolinker#system_browser, a:cfile)
        exec cmd
        return 1
    else
        return 0
    endif
endf


function! s:prototype.Jump_def(mode, cword, cfile) abort dict "{{{3
    " TLogVAR a:mode, a:cword, a:cfile
    let exact = []
    let partly = []
    for [rname, def] in items(self.defs)
        if rname ==# a:cword
            call add(exact, def.filename)
        elseif stridx(rname, a:cword)
            call add(partly, def.filename)
        endif
    endfor
    let filename = ''
    if !empty(exact)
        let matches = exact
        if len(matches) == 1
            let filename = matches[0]
        endif
    else
        let matches = partly
    endif
    if !empty(filename)
        let filename = tlib#input#List('s', 'Select file:', matches)
    endif
    " TLogVAR filename, matches
    try
        if !empty(filename)
            return self.Dispatch('Edit', '', filename)
        endif
    catch
        echohl ErrorMsg
        echom v:exception
        echom v:throwpoint
        echohl NONE
    endtry
    return 0
endf


function! s:prototype.Jump_path(mode, cword, cfile) abort dict "{{{3
    " TLogVAR a:mode, a:cword, a:cfile
    if has_key(self.globpath, a:cfile)
        let matches = self.globpath[a:cfile]
    else
        let matches = s:Globpath(&path, a:cfile .'*')
        let brx = '\V\%(\^\|\[\/]\)'. substitute(a:cfile, '[\/]', '\\[\\/]', 'g') .'.\[^.]\+\$'
        let bmatches = filter(copy(matches), 'v:val =~ brx')
        " TLogVAR brx, bmatches, matches
        if !empty(bmatches)
            let matches = bmatches
        endif
        let matches = map(matches, 'fnamemodify(v:val, ":p")')
        let matches = tlib#list#Uniq(matches)
        let self.globpath[a:cfile] = matches
    endif
    let nmatches = len(matches)
    if nmatches == 1
        let filename = matches[0]
    else
        let filename = tlib#input#List('s', 'Select file:', matches)
    endif
    if !empty(filename)
        return self.Dispatch('Edit', '', filename)
    else
        return 0
    endif
endf


function! s:prototype.Jump_tag(mode, cword, cfile) abort dict "{{{3
    " TLogVAR a:mode, a:cword, a:cfile
    try
        exec 'tab' g:autolinker#tag a:cword
        return 1
    catch /^Vim\%((\a\+)\)\=:E426/
    catch /^Vim\%((\a\+)\)\=:E433/
    endtry
    return 0
endf


function! s:prototype.Jump_fallback(mode, cword, cfile) abort dict "{{{3
    " TLogVAR a:mode, a:cword, a:cfile
    try
        let fallback = self.fallback
        if stridx(fallback, ',') != -1
            let fallbacks = split(fallback, ',')
            let fallback = tlib#input#List('s', 'Use', fallbacks)
        endif
        if !empty(fallback)
            let fallback = tlib#string#Printf1(fallback, a:cfile)
            if fallback =~# '^:'
                exec fallback
            else
                let restore = a:mode ==# 'v' ? 'gv' : ''
                exec 'norm!' restore . fallback
            endif
            return 1
        endif
    catch
        echohl ErrorMsg
        echom v:exception
        echom v:throwpoint
        echohl NONE
    endtry
    return 0
endf


