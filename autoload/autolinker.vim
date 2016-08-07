" @thor:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2016-07-28
" @Revision:    1058


if !exists('g:loaded_tlib') || g:loaded_tlib < 121
    runtime plugin/tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 121
        echoerr 'tlib >= 1.21 is required'
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
    let g:autolinker#url_rx = '\%(\l\{2,6}://\|mailto:\)[-@./[:alnum:]_+~=%#?&]\+'   "{{{2
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
    let g:autolinker#layout = {'*': {'cmd_dir': '%{CMD}', 'cmd_file': 'tab drop %{FILENAMEX}'}, 'w': {'cmd': '<count>wincmd w | %{CMD}'}, 't': {'cmd': '<count>tabn | %{CMD}'}, 's': {'cmd': '<count>split +%{CMD}'}, 'v': {'cmd': '<count>vsplit +%{CMD}'}}   "{{{2
endif


if !exists('g:autolinker#edit_file')
    " Command for opening files.
    let g:autolinker#edit_file = {'cmd': 'edit %{FILENAMEX}'}   "{{{2
endif


if !exists('g:autolinker#edit_dir')
    " Command for opening directories
    let g:autolinker#edit_dir = {'cmd': 'Explore %{FILENAMEX}'}  "{{{2
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
    " - ':'. g:autolinker#edit_file.cmd (if you want to create new files)
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
    let g:autolinker#cfile_rstrip_rx = '[\])},;:.]\s*'   "{{{2
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


let s:prototype = {'mode': 'n'
            \ , 'fallback': g:autolinker#fallback
            \ , 'types': g:autolinker#types
            \ , 'use_highlight': g:autolinker#use_highlight
            \ , 'cfile_gsub': g:autolinker#cfile_gsub
            \ , 'cfile_rstrip_rx': g:autolinker#cfile_rstrip_rx
            \ }


if v:version > 704 || (v:version == 704 && has('patch279'))
    function! s:DoGlobPath(path, pattern) abort "{{{3
        Tlibtrace 'autolinker', a:path, a:pattern
        return globpath(a:path, a:pattern, 0, 1)
    endf
else
    function! s:DoGlobPath(path, pattern) abort "{{{3
        Tlibtrace 'autolinker', a:path, a:pattern
        return split(globpath(a:path, a:pattern), '\n')
    endf
endif


function! s:IsValidCache(id) abort "{{{3
    Tlibtrace 'autolinker', a:id
    return has_key(g:autolinker_glob_cache, a:id)
endf


function! s:Globpath(path, pattern) abort "{{{3
    Tlibtrace 'autolinker', a:path, a:pattern
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
    Tlibtrace 'autolinker', len(files)
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
    Tlibtrace 'autolinker', bufnr('%'), g:autolinker#nmap, g:autolinker#imap, g:autolinker#xmap, g:autolinker#map_forward, g:autolinker#map_backward
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
    Tlibtrace 'autolinker', bufnr('%'), g:autolinker#nmap, g:autolinker#imap, g:autolinker#xmap, g:autolinker#map_forward, g:autolinker#map_backward
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
    silent! syntax clear AutoHyperlink
endf


function! s:prototype.CfileGsubRx() abort dict "{{{3
    let crx = []
    for [rx, subst; rest] in self.cfile_gsub
        let rxs = substitute(rx, '\^', '', 'g')
        " let rxs = substitute(rxs, '[\\/]', '[\\\\/]', 'g')
        let rxs = escape(rxs, '/')
        call add(crx, rxs)
    endfor
    if empty(crx)
        let rv = ''
    else
        let rv = '\m\<'. printf('\%%(%s\)', join(crx, '\|')) .'\f*'
    endif
    Tlibtrace 'autolinker', rv
    return rv
endf


function! s:prototype.Highlight() abort dict "{{{3
    Tlibtrace 'autolinker', self.use_highlight
    if !empty(self.use_highlight)
        if index(self.use_highlight, 'word') != -1
            call self.ClearHighlight()
            let rx = join(map(values(self.defs), 'v:val.rx'), '\|')
            " TLogVAR rx
            if !empty(rx)
                exec 'syntax match AutoHyperlinkWord /'. escape(rx, '/') .'/'
            endif
        endif
        if index(self.use_highlight, 'url') != -1
            exec 'syntax match AutoHyperlinkURL /'. escape(g:autolinker#url_rx, '/') .'/'
        endif
        if index(self.use_highlight, 'cfile_gsub') != -1
            let crx = self.CfileGsubRx()
            if !empty(crx)
                exec 'syntax match AutoHyperlinkCfile /'. crx .'/'
            endif
        endif
        " let col = &background == 'dark' ? 'Cyan' : 'DarkBlue'
        " exec 'hi AutoHyperlink term=underline cterm=underline gui=underline ctermfg='. col 'guifg='. col
        hi AutoHyperlinkWord term=underline cterm=underline gui=underline
        hi AutoHyperlinkURL term=underline cterm=underline gui=underline
        hi AutoHyperlinkCfile term=underline cterm=underline gui=underline
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
        call tlib#notify#PrintError()
        return 0
    endtry
endf


function! s:prototype.SplitFilename(filename) abort dict "{{{3
    Tlibtrace 'autolinker', 'SplitFilename', a:filename
    " let fragment = matchstr(a:filename, '#\zs'. g:autolinker#fragment_rx)
    let postprocess = ''
    let filename = substitute(a:filename, '^.\{-}\zs[?#].*$', '', '')
    if !(filereadable(a:filename) && !filereadable(filename))
        let query = matchstr(a:filename, '?\zs[^#]\+')
        if !empty(query)
            Tlibtrace 'autolinker', query
            if query =~# '^lnum=\d\+$'
                let postprocess = substitute(query, '^lnum=', '', '')
            elseif query =~# '^q=\S\+$'
                let postprocess = '/'. escape(substitute(query, '^q=', '', ''), '/')
            else
                throw 'autolinker.SplitFilename: Unsupported query: '. a:filename
            endif
            Tlibtrace 'autolinker', query, postprocess
            return [filename, postprocess]
        endif
        let fragment = matchstr(a:filename, '#\zs.*$')
        if !empty(fragment)
            Tlibtrace 'autolinker', fragment
            if fragment =~# '^\d\+$'
                let postprocess = fragment
            elseif fragment =~# '^lnum=\d\+$'
                " echohl WarningMsg
                " echom 'autolinker: Deprecated: Please use ?lnum=TEXT instead:' string(fragment)
                " echohl NONE
                let postprocess = substitute(fragment, '^lnum=', '', '')
            elseif fragment =~# '^q=\S\+$'
                " echohl WarningMsg
                " echom 'autolinker: Deprecated: Please use ?q=TEXT instead:' string(fragment)
                " echohl NONE
                let postprocess = '/'. escape(substitute(fragment, '^q=', '', ''), '/')
            else
                let postprocess = '/'. escape(fragment, '/')
            endif
            Tlibtrace 'autolinker', fragment, postprocess
            return [filename, postprocess]
        endif
    endif
    return [a:filename, '']
endf


function! s:prototype.GetCFile() abort dict "{{{3
    " TLogVAR self
    if !has_key(self, 'cfile')
        if stridx('in', self.mode) != -1
            if has_key(self, 'a_cfile')
                let cfile = self.a_cfile
            else
                let cfile = expand("<cfile>")
            endif
            let [cfile_raw, postprocess] = self.SplitFilename(cfile)
            Tlibtrace 'autolinker', cfile_raw, postprocess
            " TLogVAR cfile_raw, postprocess
            let self.cfile = self.CleanCFile(cfile_raw)
            if !empty(postprocess)
                let self.postprocess = tlib#url#Decode(postprocess)
            endif
            " TLogVAR self.cfile
        elseif self.mode ==# 'v'
            let self.cfile = @"
        else
            throw 'AutoLinker: Unsupported mode: '. self.mode
        endif
    endif
    Tlibtrace 'autolinker', 'GetCFile', self.cfile
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
    Tlibtrace 'autolinker', self.cword
    return self.cword
endf


function! s:prototype.GetPostprocess() abort dict "{{{3
    return get(self, 'postprocess', '')
endf


function! s:prototype.CleanCWord(text) abort dict "{{{3
    Tlibtrace 'autolinker', a:text
    return a:text
endf


function! s:prototype.CleanCFile(text, ...) abort dict "{{{3
    Tlibtrace 'autolinker', 'CleanCFile', a:text, a:000
    let strip = a:0 >= 1 ? a:1 : 1
    let text = a:text
    if strip && !empty(self.cfile_rstrip_rx)
        let text = substitute(text, self.cfile_rstrip_rx .'$', '', '')
    endif
    " TLogVAR text
    " TODO: file:// & root:// should be treated differently
    Tlibtrace 'autolinker', 1, text
    if text =~? '^[a-z0-9]\+://'
        if text =~ '^\%(file\|root\)://'
            let text = tlib#url#Decode(substitute(text, '^\%(file\|root\)://', '', ''))
        endif
    else
        if !empty(&includeexpr)
            let text = eval(substitute(&includeexpr, 'v:fname', string(a:text), 'g'))
        endif
    endif
    Tlibtrace 'autolinker', 2, text
    for [rx, sub; rest] in self.cfile_gsub
        let opts = get(rest, 0, {})
        let text1 = substitute(text, '\m\C'. rx, sub, get(opts, 'flags', 'g'))
        if get(opts, 'stop', 0) && text != text1
            break
        endif
        " TLogVAR rx, sub, text1
        let text = text1
    endfor
    Tlibtrace 'autolinker', 3, text
    return text
endf


function! s:prototype.IsInternalLink(cfile) abort dict "{{{3
    Tlibtrace 'autolinker', a:cfile
    return 0
endf


function! s:prototype.JumpInternalLink(cfile) abort dict "{{{3
    Tlibtrace 'autolinker', a:cfile
    return search('\V\^\s\*'. tlib#rx#Escape(a:cfile, 'V') .'\>') > 0
endf


function! s:prototype.Jump_internal() abort dict "{{{3
    let cfile = self.GetCFile()
    Tlibtrace 'autolinker', 'internal', cfile
    if self.IsInternalLink(cfile)
        call s:EditEdit('file', '%')
        " TLogVAR ecmd, special
        return self.JumpInternalLink(cfile)
    else
        return 0
    endif
endf


function! s:prototype.Jump_system(...) abort dict "{{{3
    let cfile = a:0 >= 1 ? a:1 : self.GetCFile()
    Tlibtrace 'autolinker', 'system', cfile
    return tlib#sys#Open(cfile)
endf


function! s:prototype.Jump_def() abort dict "{{{3
    let cword = self.GetCWord()
    Tlibtrace 'autolinker', 'def', cword
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
            let postprocess = self.GetPostprocess()
            return self.Edit(filename, postprocess)
        endif
    catch
        call tlib#notify#PrintError()
    endtry
    return 0
endf


function! s:prototype.Jump_path() abort dict "{{{3
    let cfile = self.GetCFile()
    Tlibtrace 'autolinker', 'path', cfile
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
        let postprocess = self.GetPostprocess()
        return self.Edit(filename, postprocess)
    else
        return 0
    endif
endf


function! s:prototype.Jump_tag() abort dict "{{{3
    let cword = self.GetCWord()
    Tlibtrace 'autolinker', 'tag', cword
    try
        exec 'tab' g:autolinker#tag cword
        return 1
    catch /^Vim\%((\a\+)\)\=:E73/
    catch /^Vim\%((\a\+)\)\=:E426/
    catch /^Vim\%((\a\+)\)\=:E433/
    endtry
    return 0
endf


function! s:prototype.Jump_fallback() abort dict "{{{3
    let cfile = self.GetCFile()
    " let postprocess = self.GetPostprocess()
    " TLogVAR cfile, postprocess
    Tlibtrace 'autolinker', 'fallback', cfile
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
        call tlib#notify#PrintError()
    endtry
    return 0
endf


function! autolinker#Ensure() abort "{{{3
    Tlibtrace 'autolinker', exists('b:autolinker')
    if !exists('b:autolinker')
        call autolinker#EnableBuffer()
    endif
    return b:autolinker
endf


function! autolinker#EnableFiletype() abort "{{{3
    exec 'autocmd! AutoLinker' g:autolinker_install_syntax_events '<buffer>'
    call autolinker#EnableBuffer()
endf


let s:ft_prototypes = {}

function! autolinker#EnableBuffer() abort "{{{3
    let ft = &ft
    if empty(ft)
        let ft = '<NONE>'
    endif
    Tlibtrace 'autolinker', ft
    if !has_key(s:ft_prototypes, ft)
        let prototype = deepcopy(s:prototype)
        for fft in tlib#list#Uniq([ft, substitute(ft, '\..\+$', '', ''), ''])
            Tlibtrace 'autolinker', fft
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
    Tlibtrace 'autolinker', len(b:autolinker)
    let b:autolinker.defs = b:autolinker.WordLinks()
    call b:autolinker.Highlight()
    call b:autolinker.InstallHotkey()
    for c in ['t', 'w', 'v', 's']
        let cmap = printf(g:autolinker#map_options, c)
        " Tlibtrace 'autolinker', cmap
        exec 'nnoremap' cmap ':<C-U>let w:autolinker_'. c '= v:count<cr>'
    endfor
    call tlib#balloon#Register('autolinker#Balloon()')
    let b:undo_ftplugin = 'call autolinker#DisableBuffer()'. (exists('b:undo_ftplugin') ? '|'. b:undo_ftplugin : '')
    Tlibtrace 'autolinker', b:undo_ftplugin
endf


function! autolinker#DisableBuffer() abort "{{{3
    Tlibtrace 'autolinker', &ft
    if exists('b:autolinker')
        call tlib#balloon#Remove('autolinker#Balloon()')
        call b:autolinker.ClearHighlight()
        call b:autolinker.UninstallHotkey()
        unlet! b:autolinker b:undo_ftplugin
    " else
    "     echohl WarningMsg
    "     echom 'Autolinker: Internal error in DisableBuffer: b:autolinker is not defined (bufnr='. bufnr('%') .')'
    "     echohl NONE
    endif
endf


function! autolinker#Balloon() abort "{{{3
    let autolinker = autolinker#Ensure()
    let cfile = tlib#balloon#Expand('<cfile>')
    let cfile = autolinker.CleanCFile(cfile)
    Tlibtrace 'autolinker', cfile
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
    Tlibtrace 'autolinker', a:mode
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


function! autolinker#Edit(cfile) abort "{{{3
    Tlibtrace 'autolinker', a:cfile
    let autolinker = copy(autolinker#Ensure())
    let autolinker.a_cfile = a:cfile
    call s:Jump(autolinker, 0)
endf


function! autolinker#EditInPath(cfile) abort "{{{3
    Tlibtrace 'autolinker', a:cfile
    if tlib#file#IsAbsolute(a:cfile)
        let filename = a:cfile
    else
        let path = filter(split(&path, ','), '!empty(v:val)')
        Tlibtrace 'autolinker', path
        let filenames = map(path, 'tlib#file#Join([v:val, a:cfile], 1, 1)')
        Tlibtrace 'autolinker', filenames
        call insert(filenames, a:cfile)
        let filenames = map(filenames, 'fnamemodify(v:val, ":p")')
        let filenames = tlib#list#Uniq(filenames)
        let filename = tlib#input#List('s', 'Select file:', filenames)
    endif
    return s:Edit(filename, '')
endf


function! s:GetEditCmd(what, filename) abort "{{{3
    Tlibtrace 'autolinker', a:what, a:filename
    let cmd = g:autolinker#edit_{a:what}
    let cnt = ''
    let special = 1
    if exists('w:autolinker_t')
        Tlibtrace 'autolinker', w:autolinker_t
        let editdef = g:autolinker#layout.t
        let cnt = w:autolinker_t
        unlet w:autolinker_t
    elseif exists('w:autolinker_w')
        Tlibtrace 'autolinker', w:autolinker_w
        let editdef = g:autolinker#layout.w
        let cnt = w:autolinker_w
        unlet w:autolinker_w
    elseif exists('w:autolinker_v')
        Tlibtrace 'autolinker', w:autolinker_v
        let editdef = g:autolinker#layout.v
        let cnt = w:autolinker_v
        unlet w:autolinker_v
    elseif exists('w:autolinker_s')
        Tlibtrace 'autolinker', w:autolinker_s
        let editdef = g:autolinker#layout.s
        let cnt = w:autolinker_s
        unlet w:autolinker_s
    else
        let editdef = g:autolinker#layout['*']
        let special = 0
    endif
    Tlibtrace 'autolinker', cnt, editdef, special
    if cnt == 0
        let cnt = ''
    endif
    let ecmdf = get(editdef, 'cmd_'. a:what, get(editdef, 'cmd', ''))
    if empty(ecmdf)
        throw 'Autolinker: Either cmd_'. a:what .' or cmd must be defined for g:autolinker#edit_'. a:what
    endif
    let ecmdt = substitute(ecmdf, '<count>', cnt, 'g')
    let eargs = {}
    if a:filename == '%'
        let eargs.FILENAME = a:filename
        let eargs.FILENAMEX = a:filename
        let eargs.FILENAME_SHELL = shellescape(a:filename)
    else
        let eargs.FILENAME = a:filename
        let eargs.FILENAMEX = fnameescape(a:filename)
        let eargs.FILENAME_SHELL = shellescape(a:filename, 1)
    endif
    let eargs.CMD = tlib#string#Format(cmd.cmd, eargs)
    if get(cmd, 'ignore_layout', 0)
        let ecmd = eargs.CMD
    else
        let ecmd = tlib#string#Format(ecmdt, eargs)
    endif
    Tlibtrace 'autolinker', ecmd, special
    return {'cmd': ecmd, 'filename': a:filename, 'special': special}
endf


function! s:Edit(filename, postprocess) abort "{{{3
    Tlibtrace 'autolinker', a:filename
    if !empty(a:filename)
        let what = isdirectory(a:filename) ? 'dir' : 'file'
        call s:EditEdit(what, a:filename)
        if !empty(a:postprocess)
            try
                silent exec a:postprocess
            catch
                call tlib#notify#PrintError()
            endtry
        endif
        return 1
    endif
    return 0
endf


function! s:EditEdit(what, filename) abort "{{{2
    let editdef = s:GetEditCmd(a:what, a:filename)
    Tlibtrace 'autolinker', a:what, a:filename, editdef
    if a:filename !~ '^[%]$'
        call tlib#dir#Ensure(fnamemodify(a:filename, ':p:h'))
    endif
    try
        exec editdef.cmd
    catch /^Vim\%((\a\+)\)\=:E325/
    endtry
endf


function! s:GetRx() abort "{{{3
    if !exists('b:autolinker')
        return ''
    else
        let rxs = []
        let rxs += map(values(b:autolinker.defs), 'v:val.rx')
        let rxs += g:tlib#sys#special_protocols
        let crx = b:autolinker.CfileGsubRx()
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
            if subst =~# '\\\@<!\\\d'
                let subst1 = substitute(subst, '\\\@<!\\\d', '*', 'g')
                let subst1 = substitute(subst1, '\\\\', '\\', 'g')
                call add(globs, subst1)
            else
                call add(globs, tlib#file#Join([subst, pattern]))
            endif
        endif
    endfor
    Tlibtrace 'autolinker', globs
    " TLogVAR globs
    return globs
endf


function! autolinker#CompleteFilename(ArgLead, CmdLine, CursorPos) abort "{{{3
    let prototype = deepcopy(s:prototype)
    " TLogVAR a:ArgLead
    let names = filter(map(copy(g:autolinker#cfile_gsub), 'v:val[0]'), 'v:val =~# ''^\^''')
    let names = map(names, 'substitute(v:val, ''^\^'', "", "")')
    Tlibtrace 'autolinker', names
    if !empty(a:ArgLead)
        let nchars = len(a:ArgLead)
        let names = filter(names, 'strpart(v:val, 0, nchars) ==# a:ArgLead')
        Tlibtrace 'autolinker', a:ArgLead, names
    endif
    let filenames = []
    if isdirectory(a:ArgLead)
        let dir = tlib#file#Join([a:ArgLead, ''])
        if a:ArgLead !=# dir
            call add(filenames, dir)
        endif
        let pattern = tlib#file#Join([a:ArgLead, '*'])
    else
        let pattern = a:ArgLead .'*'
    endif
    " TLogVAR pattern
    call extend(filenames, tlib#file#Globpath(&path, prototype.CleanCFile(pattern, 0)))
    " TLogVAR len(filenames)
    let rv = sort(names) + sort(filenames)
    let rv = map(rv, 'escape(v:val, '' '')')
    return rv
endf


