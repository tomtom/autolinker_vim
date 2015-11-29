" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-11-29
" @Revision:    836


if !exists('g:loaded_tlib') || g:loaded_tlib < 115
    runtime plugin/tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 115
        echoerr 'tlib >= 1.15 is required'
        finish
    endif
endif


if !exists('g:autolinker#use_highlight')
    " Items that should be highlighted as hyperlinks:
    " - word
    " - url
    " - cfile_gsub
    let g:autolinker#use_highlight = ['word', 'url', 'cfile_gsub']   "{{{2
endif


if !exists('g:autolinker#url_rx')
    let g:autolinker#url_rx = '\l\{2,6}://[-./[:alnum:]_~%#?&]\+'   "{{{2
    " let g:autolinker#url_rx = '\<\%(ht\|f\)tps\?:\/\/\f\+'   "{{{2
endif


if !exists('g:autolinker#types')
    " Possible values (the order is significant):
    " - internal (a document-internal reference)
    " - system (URLs, non-text files etc. matching 
    "   |g:autolinker#system_rx|)
    " - def (files in the current directory)
    " - path (files in 'path')
    " - tag (tags)
    " - fallback (see |g:autolinker#fallback|)
    let g:autolinker#types = ['internal', 'system', 'path', 'def', 'tag', 'fallback']   "{{{2
endif


if !exists('g:autolinker#nmap')
    " Normal mode map.
    let g:autolinker#nmap = 'gz'   "{{{2
endif


if !exists('g:autolinker#imap')
    " Insert mode map.
    let g:autolinker#imap = '<unique> <c-cr>'   "{{{2
endif


if !exists('g:autolinker#xmap')
    " Visual mode map.
    let g:autolinker#xmap = g:autolinker#nmap   "{{{2
endif


if !exists('g:autolinker#map_forward')
    let g:autolinker#map_forward = ']'. g:autolinker#nmap   "{{{2
endif


if !exists('g:autolinker#map_backward')
    let g:autolinker#map_backward = '['. g:autolinker#nmap   "{{{2
endif


if !exists('g:autolinker#map_options')
    " Call this map with a count and a char (w = window, t = tab, s = 
    " split, v = vertical split) to define where the destination should 
    " be displayed.
    "
    " Let's assume |maplocalleader| is '\'. Then, e.g.,
    "   \asgz .... Open the destination in a split buffer
    "   2\awgz ... Open the destination in the second window
    let g:autolinker#map_options = '<LocalLeader>a%s'   "{{{2
endif


if !exists('g:autolinker#layout')
    " Command for working with layouts.
    let g:autolinker#layout = {'*': ['tab drop', 'fnameescape'], 'w': ['<count>wincmd w'], 't': ['<count>tabn'], 's': ['<count>split'], 'v': ['vert <count>split']}   "{{{2
endif


if !exists('g:autolinker#edit_file')
    " Command for opening files.
    let g:autolinker#edit_file = ['edit', 'fnameescape']   "{{{2
endif


if !exists('g:autolinker#edit_dir')
    " Command for opening directories
    let g:autolinker#edit_dir = ['Explore']  "{{{2
endif


if !exists('g:autolinker#tag')
    let g:autolinker#tag = 'tselect'   "{{{2
endif


if !exists('g:autolinker#fallback')
    " A comma-separated list of fallback procedures.
    " Normal command to run when everything else fails.
    " If the command starts with ':', it is an ex command.
    " branch to use.
    "
    " The arguments are format strings for |printf|. Any `%s` will be 
    " replaced with |<cfile>|. A `%` must be written as `%%`.
    "
    " Possible values are:
    " - gf
    " - ':'. g:autolinker#edit_file[0] (if you want to create new files)
    let g:autolinker#fallback = ':call autolinker#EditInPath("%s"),gf,gx'   "{{{2
endif


if !exists('g:autolinker#index')
    " The value is an expression that evaluates to the filename.
    " When opening directories, check whether a file with that name 
    " exists. If so, open that file instead of the directory.
    let g:autolinker#index = '"index.". expand("%:e")'   "{{{2
endif


if !exists('g:autolinker#cfile_gsub')
    " A list of lists [RX, SUB, optional: {OPT => VALUE}] that are 
    " applied to the |<cfile>| under the cursor. This can be used to 
    " rewrite filenames and URLs, in order to implement e.g. interwikis.
    "
    " RX must be a |magic| |regexp|.
    "
    " Options:
    "   flags = 'g' ... flags for |substitute()|
    "   stop = 0 ...... Don't process other gsubs when this |regexp| 
    "                   matches
    "
    " Examples:
    " ["^WIKI/", "~/MyWiki/"] .............. Redirect to wiki
    " ["^todo://", "~/data/simpletask/"] ... Use todo pseudo-protocol as 
    "                                        used by the simpletasks app
    let g:autolinker#cfile_gsub = []   "{{{2
endif


if !exists('g:autolinker#cfile_rstrip_rx')
    " Strip a suffix matching this |regexp| from cfile.
    let g:autolinker#cfile_rstrip_rx = '[])},;:.]\s*'   "{{{2
endif


if !exists('g:autolinker#find_ignore_rx')
    " |autolinker#Find()| ignores substitutions from 
    " |g:autolinker#cfile_gsub| that match this |regexp|.
    let g:autolinker#find_ignore_rx = ''   "{{{2
endif


if !exists('g:autolinker#find_ignore_subst')
    " |autolinker#Find()| ignores substitutions from 
    " |g:autolinker#cfile_gsub| that match this |regexp|.
    let g:autolinker#find_ignore_subst = '^\a\{2,}:'   "{{{2
endif


if !exists('g:autolinker#fragment_rx')
    let g:autolinker#fragment_rx = '\%(\d\+\|lnum=\d\+\|q=\S\+\)$'   "{{{2
endif


let s:prototype = {'fallback': g:autolinker#fallback
            \ , 'types': g:autolinker#types
            \ , 'use_highlight': g:autolinker#use_highlight
            \ , 'cfile_gsub': g:autolinker#cfile_gsub
            \ , 'cfile_rstrip_rx': g:autolinker#cfile_rstrip_rx
            \ }


if v:version > 704 || (v:version == 704 && has('patch279'))
    function! s:DoGlobPath(path, pattern) abort "{{{3
        return globpath(a:path, a:pattern, 0, 1)
    endf
else
    function! s:DoGlobPath(path, pattern) abort "{{{3
        return split(globpath(a:path, a:pattern), '\n')
    endf
endif


function! s:IsValidCache(id) abort "{{{3
    return has_key(g:autolinker_glob_cache, a:id)
endf


function! s:Globpath(path, pattern) abort "{{{3
    let id = join([getcwd(), a:path, a:pattern], '|')
    if s:IsValidCache(id)
        let matches = g:autolinker_glob_cache[id].files
    else
        let matches = s:DoGlobPath(a:path, a:pattern)
        let matches = map(matches, 'fnamemodify(v:val, ":p")')
        let matches = tlib#list#Uniq(matches)
        let g:autolinker_glob_cache[id] = {'files': matches}
    endif
    return matches
endf


function! s:prototype.WordLinks() dict abort "{{{3
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


function! s:prototype.UninstallHotkey() abort dict "{{{3
    if !empty(g:autolinker#nmap)
        exec 'silent! nunmap <buffer>' g:autolinker#nmap
    endif
    if !empty(g:autolinker#imap)
        exec 'silent! iunmap <buffer>' g:autolinker#imap
    endif
    if !empty(g:autolinker#xmap)
        exec 'silent! xunmap <buffer>' g:autolinker#xmap
    endif
    if !empty(g:autolinker#map_forward)
        exec 'silent! nunmap' g:autolinker#map_forward
    endif
    if !empty(g:autolinker#map_backward)
        exec 'silent! nunmap' g:autolinker#map_backward
    endif
endf


function! s:prototype.InstallHotkey() abort dict "{{{3
    if !empty(g:autolinker#nmap)
        exec 'silent! nnoremap <buffer>' g:autolinker#nmap ':call autolinker#Jump("n")<cr>'
    endif
    if !empty(g:autolinker#imap)
        exec 'silent! inoremap <buffer>' g:autolinker#imap '<c-\><c-o>:call autolinker#Jump("i")<cr>'
    endif
    if !empty(g:autolinker#xmap)
        exec 'silent! xnoremap <buffer>' g:autolinker#xmap '""y:call autolinker#Jump("v")<cr>'
    endif
    if !empty(g:autolinker#map_forward)
        exec 'silent! nnoremap' g:autolinker#map_forward ':<C-U>call autolinker#NextLink(v:count1)<cr>'
    endif
    if !empty(g:autolinker#map_backward)
        exec 'silent! nnoremap' g:autolinker#map_backward ':<C-U>call autolinker#NextLink(- v:count1)<cr>'
    endif
endf


function! s:prototype.ClearHighlight() abort dict "{{{3
    silent! syn clear AutoHyperlink
endf


function! s:prototype.CfileGsubRx(add_f) abort dict "{{{3
    let crx = []
    for [rx, subst; rest] in self.cfile_gsub
        let rxs = substitute(rx, '\^', '\\<', 'g')
        let rxs = '\m'. escape(rxs, '/') .'\f*'
        if a:add_f
            let rxs .= '\f*'
        endif
        call add(crx, rxs)
    endfor
    return empty(crx) ? '' : printf('\%%(%s\)', join(crx, '\|'))
endf


function! s:prototype.Highlight() abort dict "{{{3
    if !empty(self.use_highlight)
        if index(self.use_highlight, 'word')
            call self.ClearHighlight()
            let rx = join(map(values(self.defs), 'v:val.rx'), '\|')
            if !empty(rx)
                exec 'syn match AutoHyperlink /'. escape(rx, '/') .'/'
            endif
        endif
        if index(self.use_highlight, 'url')
            exec 'syn match AutoHyperlink /'. escape(g:autolinker#url_rx, '/') .'/'
        endif
        if index(self.use_highlight, 'cfile_gsub')
            let crx = self.CfileGsubRx(1)
            if !empty(crx)
                exec 'syn match AutoHyperlink /'. crx .'/'
            endif
        endif
        " let col = &background == 'dark' ? 'Cyan' : 'DarkBlue'
        " exec 'hi AutoHyperlink term=underline cterm=underline gui=underline ctermfg='. col 'guifg='. col
        hi AutoHyperlink term=underline cterm=underline gui=underline
    endif
endf


function! s:prototype.Edit(filename, postprocess) abort dict "{{{3
    Tlibtrace 'autolinker', a:filename
    try
        if !self.Jump_system(a:filename)
            let filename = a:filename
            if isdirectory(filename)
                let index = filename .'/'. eval(g:autolinker#index)
                if filereadable(index)
                    let filename = index
                endif
            endif
            call s:Edit(filename, a:postprocess)
            call autolinker#Ensure()
        endif
        return 1
    catch
        echohl ErrorMsg
        echom v:exception
        echom v:throwpoint
        echohl NONE
        return 0
    endtry
endf


function! s:prototype.SplitFilename(filename) abort dict "{{{3
    let fragment = matchstr(a:filename, '#\zs'. g:autolinker#fragment_rx)
    if !empty(fragment)
        let filename = substitute(a:filename, '^.\{-}\zs#'. g:autolinker#fragment_rx, '', '')
        if !(filereadable(a:filename) && !filereadable(filename))
            if fragment =~# '^\d\+$'
                let postprocess = fragment
            elseif fragment =~# '^lnum=\d\+$'
                let postprocess = substitute(fragment, '^lnum=', '', '')
            elseif fragment =~# '^q=\S\+$'
                let postprocess = '/'. escape(substitute(fragment, '^q=', '', ''), '/')
            else
                throw 'autolinker.SplitFilename: Internal error: '. a:filename
            endif
            Tlibtrace 'autolinker', filename, postprocess
            return [filename, postprocess]
        endif
    endif
    return [a:filename, '']
endf


function! s:prototype.GetCFile() abort dict "{{{3
    if !has_key(self, 'cfile')
        if stridx('in', self.mode) != -1
            let self.cfile = expand("<cfile>")
            " TLogVAR 1, self.cfile
            let self.cfile = self.CleanCFile(self.cfile)
            " TLogVAR 2, self.cfile
        elseif self.mode ==# 'v'
            let self.cfile = @"
        else
            throw 'AutoLinker: Unsupported mode: '. self.mode
        endif
    endif
    return self.cfile
endf


function! s:prototype.GetCWord() abort dict "{{{3
    if !has_key(self, 'cword')
        if stridx('in', self.mode) != -1
            let self.cword = expand("<cword>")
            let self.cword = self.CleanCWord(self.cword)
            " TLogVAR cword
        elseif self.mode ==# 'v'
            let self.cword = @"
        else
            throw 'AutoLinker: Unsupported mode: '. self.mode
        endif
    endif
    return self.cword
endf


function! s:prototype.CleanCWord(text) abort dict "{{{3
    return a:text
endf


function! s:prototype.CleanCFile(text, ...) abort dict "{{{3
    let strip = a:0 >= 1 ? a:1 : 1
    let text = a:text
    if strip && !empty(self.cfile_rstrip_rx)
        let text = substitute(text, self.cfile_rstrip_rx .'$', '', '')
    endif
    if !empty(&includeexpr)
        let text = eval(substitute(&includeexpr, 'v:fname', string(a:text), 'g'))
    endif
    " TLogVAR text
    if text =~ '^file://'
        let text = tlib#url#Decode(substitute(text, '^file://', '', ''))
    endif
    for [rx, sub; rest] in self.cfile_gsub
        let opts = get(rest, 0, {})
        let text1 = substitute(text, '\m\C'. rx, sub, get(opts, 'flags', 'g'))
        if get(opts, 'stop', 0) && text != text1
            break
        endif
        " TLogVAR rx, sub, text1
        let text = text1
    endfor
    return text
endf


function! s:prototype.IsInternalLink(cfile) abort dict "{{{3
    return 0
endf


function! s:prototype.JumpInternalLink(cfile) abort dict "{{{3
    return search('\V\^\s\*'. tlib#rx#Escape(a:cfile, 'V') .'\>') > 0
endf


function! s:prototype.Jump_internal() abort dict "{{{3
    let cfile = self.GetCFile()
    Tlibtrace 'autolinker', cfile
    if self.IsInternalLink(cfile)
        let [editdef, special] = s:GetEditCmd('file')
        " TLogVAR edit, special
        if special
            call s:EditEdit(expand('%:p'), editdef)
        endif
        return self.JumpInternalLink(cfile)
    else
        return 0
    endif
endf


function! s:prototype.Jump_system(...) abort dict "{{{3
    let cfile = a:0 >= 1 ? a:1 : self.GetCFile()
    Tlibtrace 'autolinker', cfile
    return tlib#sys#Open(cfile)
endf


" function! s:prototype.Jump_fileurl(mode, cword, cfile) abort dict "{{{3
"     Tlibtrace 'autolinker', a:mode, a:cword, a:cfile
"     if a:cfile =~ '^file://'
"         let cfile = tlib#url#Decode(substitute(a:cfile, '^file://', '', ''))
"         let cfile = self.CleanCFile(cfile)
"         Tlibtrace 'autolinker', a:cfile, cfile
"         return self.Edit(cfile, '')
"     endif
"     return 0
" endf


function! s:prototype.Jump_def() abort dict "{{{3
    let [cword, postprocess] = self.SplitFilename(self.GetCWord())
    Tlibtrace 'autolinker', cword
    let exact = []
    let partly = []
    for [rname, def] in items(self.defs)
        if rname ==# cword
            call add(exact, def.filename)
        elseif stridx(rname, cword)
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
            return self.Edit(filename, postprocess)
        endif
    catch
        echohl ErrorMsg
        echom v:exception
        echom v:throwpoint
        echohl NONE
    endtry
    return 0
endf


function! s:prototype.Jump_path() abort dict "{{{3
    let [cfile, postprocess] = self.SplitFilename(self.GetCFile())
    Tlibtrace 'autolinker', cfile
    let matches = s:Globpath(&path, cfile .'*')
    let brx = '\C\V\%(\^\|\[\/]\)'. substitute(cfile, '[\/]', '\\[\\/]', 'g') .'.\[^.]\+\$'
    let bmatches = filter(copy(matches), 'v:val =~ brx')
    " TLogVAR brx, bmatches, matches
    if !empty(bmatches)
        let matches = bmatches
    endif
    let nmatches = len(matches)
    if nmatches == 1
        let filename = matches[0]
    else
        let filename = tlib#input#List('s', 'Select file:', matches)
    endif
    if !empty(filename)
        return self.Edit(filename, postprocess)
    else
        return 0
    endif
endf


function! s:prototype.Jump_tag() abort dict "{{{3
    let cword = self.GetCWord()
    Tlibtrace 'autolinker', cword
    try
        exec 'tab' g:autolinker#tag cword
        return 1
    catch /^Vim\%((\a\+)\)\=:E426/
    catch /^Vim\%((\a\+)\)\=:E433/
    endtry
    return 0
endf


function! s:prototype.Jump_fallback() abort dict "{{{3
    let [cfile, postprocess] = self.SplitFilename(self.GetCFile())
    Tlibtrace 'autolinker', cfile
    try
        let fallback = self.fallback
        if stridx(fallback, ',') != -1
            let fallbacks = map(split(fallback, ','), 'tlib#string#Printf1(v:val, cfile)')
            let fallback = tlib#input#List('s', 'Use', fallbacks)
        endif
        if !empty(fallback)
            if fallback =~# '^:'
                exec fallback
            else
                let restore = self.mode ==# 'v' ? 'gv' : ''
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


function! autolinker#Ensure() abort "{{{3
    if !exists('b:autolinker')
        call autolinker#EnableBuffer()
    endif
    return b:autolinker
endf


let s:ft_prototypes = {}

function! autolinker#EnableBuffer() abort "{{{3
    let ft = &ft
    if !has_key(s:ft_prototypes, ft)
        let prototype = deepcopy(s:prototype)
        for fft in [ft, substitute(ft, '\..\+$', '', ''), '']
            if empty(fft)
                let s:ft_prototypes[ft] = prototype
            else
                try
                    let fft_ = substitute(fft, '\W', '_', 'g')
                    let s:ft_prototypes[ft] = autolinker#ft_{fft_}#GetInstance(prototype)
                catch /^Vim\%((\a\+)\)\=:E117/
                    continue
                endtry
            endif
            break
        endfor
    endif
    let b:autolinker = copy(s:ft_prototypes[ft])
    let b:autolinker.defs = b:autolinker.WordLinks()
    call b:autolinker.Highlight()
    call b:autolinker.InstallHotkey()
    for c in ['t', 'w', 'v', 's']
        exec 'nnoremap' printf(g:autolinker#map_options, c) ':<C-U>let w:autolinker_'. c '= v:count<cr>'
    endfor
    call tlib#balloon#Register('autolinker#Balloon()')
    let b:undo_ftplugin = 'call autolinker#DisableBuffer()'. (exists('b:undo_ftplugin') ? '|'. b:undo_ftplugin : '')
endf


function! autolinker#DisableBuffer() abort "{{{3
    call tlib#balloon#Remove('autolinker#Balloon()')
    call b:autolinker.ClearHighlight()
    call b:autolinker.UninstallHotkey()
    unlet! b:autolinker
endf


function! autolinker#Balloon() abort "{{{3
    let autolinker = autolinker#Ensure()
    let cfile = tlib#balloon#Expand('<cfile>')
    let cfile = autolinker.CleanCFile(cfile)
    " TLogVAR cfile, tlib#sys#IsSpecial(cfile), filereadable(cfile)
    if !tlib#sys#IsSpecial(cfile) && filereadable(cfile)
        let lines = readfile(cfile)
        return join(lines[0 : 5], "\n")
    elseif isdirectory(cfile)
        let items = tlib#file#Glob(tlib#file#Join([cfile, '*']))
        return join(items[0 : 5], "\n")
    endif
endf


" Jump to the destination descibed by the word under the cursor. Use one 
" of the following methods (see |g:autolinker#types|):
" 1. Jump by definition (depends on filetype; by default all files in the 
"    current directory)
" 2. Jump to special URLs matching |g:autolinker#system_rx|
" 3. Jump to a file in 'path' mathing the word under cursor
" 4. Jump to a tag
" As last resort use |g:autolinker#fallback|
function! autolinker#Jump(mode) abort "{{{3
    let autolinker = copy(autolinker#Ensure())
    let autolinker.mode = a:mode
    call s:Jump(autolinker, 0)
endf


let s:blacklist_recursive = ['fallback', 'internal']


function! s:Jump(autolinker, recursive) abort "{{{3
    Tlibtrace 'autolinker', a:recursive, a:autolinker.types
    for type in a:autolinker.types
        if !a:recursive || index(s:blacklist_recursive, type) == -1
            let method = 'Jump_'. type
            Tlibtrace 'autolinker', method
            if has_key(a:autolinker, method) && call(a:autolinker[method], [], a:autolinker)
                Tlibtrace 'autolinker', 'ok'
                return 1
            endif
        endif
    endfor
    if !a:recursive
        echom 'Autolinker: I can''t dance --' a:autolinker.GetCFile()
        let wvars = filter(w:, 'v:val =~ "^autolinker_"')
        if !empty(wvars)
            exec 'unlet!' join(keys(map(wvars, '"w:". v:val')))
        endif
    endif
    return 0
endf


" function! autolinker#Edit(cfile) abort "{{{3
"     let autolinker = autolinker#Ensure()
"     call s:Jump(autolinker, 'n', a:cfile, a:cfile, 0)
" endf


function! autolinker#EditInPath(cfile) abort "{{{3
    let path = filter(split(&path, ','), '!empty(v:val)')
    let filenames = map(path, 'tlib#file#Join([v:val, a:cfile], 1, 1)')
    call insert(filenames, a:cfile)
    let filenames = map(filenames, 'fnamemodify(v:val, ":p")')
    let filenames = tlib#list#Uniq(filenames)
    let filename = tlib#input#List('s', 'Select file:', filenames)
    return s:Edit(filename, '')
endf


function! s:GetEditCmd(what) abort "{{{3
    let cmd = g:autolinker#edit_{a:what}
    let cnt = ''
    if exists('w:autolinker_t')
        let editdef = g:autolinker#layout.t
        let cnt = w:autolinker_t
        let special = 1
    elseif exists('w:autolinker_w')
        let editdef = g:autolinker#layout.w
        let cnt = w:autolinker_w
        let special = 1
    elseif exists('w:autolinker_v')
        let editdef = g:autolinker#layout.v
        let cnt = w:autolinker_v
        let special = 1
    elseif exists('w:autolinker_s')
        let editdef = g:autolinker#layout.s
        let cnt = w:autolinker_s
        let special = 1
    else
        let editdef = g:autolinker#layout['*']
        let special = 0
    endif
    if cnt == 0
        let cnt = ''
    endif
    let editdef[0] = substitute(editdef[0], '<count>', cnt, 'g')
    if !special
        if a:what ==# 'dir'
            let editdef = cmd
        elseif a:what ==# 'file'
        endif
    else
        let editdef[0] .= '|'. cmd[0]
        let editdef[1] = get(cmd, 1, '')
    endif
    return [editdef, special]
endf


function! s:Edit(filename, postprocess) abort "{{{3
    Tlibtrace 'autolinker', a:filename
    if !empty(a:filename)
        let what = isdirectory(a:filename) ? 'dir' : 'file'
        let [editdef, special] = s:GetEditCmd(what)
        Tlibtrace 'autolinker', what, editdef, special
        call s:EditEdit(a:filename, editdef)
        if !empty(a:postprocess)
            exec a:postprocess
        endif
        return 1
    endif
    return 0
endf


function! s:EditEdit(filename, editdef) abort "{{{3
    let filename = a:filename
    let fescape = get(a:editdef, 1, '')
    if !empty(fescape)
        let filename = call(fescape, [filename])
    endif
    call tlib#dir#Ensure(fnamemodify(a:filename, ':p:h'))
    exec a:editdef[0] filename
endf


function! s:GetRx() abort "{{{3
    if !exists('b:autolinker')
        return ''
    else
        let rxs = []
        let rxs += map(values(b:autolinker.defs), 'v:val.rx')
        let rxs += g:tlib#sys#special_protocols
        let crx = b:autolinker.CfileGsubRx(0)
        if !empty(crx)
            call add(rxs, crx)
        endif
        return printf('\(%s\)', join(rxs, '\|'))
    endif
endf


function! autolinker#NextLink(n) abort "{{{3
    let rx = s:GetRx()
    let n = abs(a:n)
    let flags = 'sw'. (a:n < 0 ? 'b' : '')
    for i in range(n)
        if !search(rx, flags)
            break
        endif
    endfor
endf


function! autolinker#FileSources(opts) abort "{{{3
    let globs = []
    let cfile_gsub = exists('b:autolinker') ? b:autolinker.cfile_gsub : g:autolinker#cfile_gsub
    let pattern = get(a:opts, 'glob', get(a:opts, 'deep', 1) ? '**' : '*')
    for [rx, subst; rest] in cfile_gsub
        if rx =~ '^\^'
                    \ && (empty(g:autolinker#find_ignore_rx) || rx !~ g:autolinker#find_ignore_rx)
                    \ && (empty(g:autolinker#find_ignore_subst) || subst !~ g:autolinker#find_ignore_subst)
            call add(globs, tlib#file#Join([subst, pattern]))
        endif
    endfor
    Tlibtrace 'autolinker', globs
    " TLogVAR globs
    return globs
endf


function! autolinker#CompleteFilename(ArgLead, CmdLine, CursorPos) abort "{{{3
    let prototype = deepcopy(s:prototype)
    " TLogVAR a:ArgLead
    let filename = prototype.CleanCFile(a:ArgLead .'*', 0)
    " TLogVAR filename
    let filenames = tlib#file#Globpath(&path, filename)
    " TLogVAR len(filenames)
    return sort(filenames)
endf


function! s:ParseCFile(cfile) abort "{{{3
    let post = matchstr(a:cfile, '@\%(/\S\+\|\d\+\)$')
endf

