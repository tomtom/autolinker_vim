" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-09-30
" @Revision:    491


if !exists('g:loaded_tlib') || g:loaded_tlib < 114
    runtime plugin/tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 114
        echoerr 'tlib >= 1.14 is required'
        finish
    endif
endif


if !exists('g:autolinker#use_highlight')
    " Items that should be highlighted as hyperlinks:
    " - word
    " - url
    let g:autolinker#use_highlight = ['word', 'url']   "{{{2
endif


if !exists('g:autolinker#url_rx')
    let g:autolinker#url_rx = '\l\{2,6}://[-./[:alnum:]_~%#?&]\+'   "{{{2
    " let g:autolinker#url_rx = '\<\%(ht\|f\)tps\?:\/\/\f\+'   "{{{2
endif


if !exists('g:autolinker#types')
    " Possible values (the order is significant):
    " - system (URLs, non-text files etc. matching 
    "   |g:autolinker#system_rx|)
    " - def (files in the current directory)
    " - path (files in 'path')
    " - tag (tags)
    " - fallback (see |g:autolinker#fallback|)
    let g:autolinker#types = ['system', 'path', 'def', 'tag', 'fallback']   "{{{2
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


if !exists('g:autolinker#edit')
    " Command for editing files.
    let g:autolinker#edit = 'tab drop'   "{{{2
endif


if !exists('g:autolinker#tag')
    let g:autolinker#tag = 'tag'   "{{{2
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
    " - ':'. g:autolinker#edit (if you want to create new files)
    let g:autolinker#fallback = ':call autolinker#EditInPath("%s"),gf'   "{{{2
endif


if !exists('g:autolinker#index')
    " The value is an expression that evaluates to the filename.
    " When opening directories, check whether a file with that name 
    " exists. If so, open that file instead of the directory.
    let g:autolinker#index = '"index.". expand("%:e")'   "{{{2
endif


if !exists('g:autolinker#special_protocols')
    " Open links matching this rx with |g:autolinker#system_browser|.
    let g:autolinker#system_rx = '\%(^\%(https\?\|nntp\|mailto\):\|\.\%(xlsx\?\|docx\?\|pptx\?\|accdb\|mdb\|sqlite\|pdf\)\)'   "{{{2
endif


if !exists("g:autolinker#system_browser")
    if exists('g:netrw_browsex_viewer')
        " Open files in the system browser.
        " :read: let g:autolinker#system_browser = ... "{{{2
        let g:autolinker#system_browser = "exec 'silent !'. g:netrw_browsex_viewer shellescape('%s')" "{{{2
    elseif has("win32") || has("win16") || has("win64")
        " let g:autolinker#system_browser = "exec 'silent ! start \"\"' shellescape('%s')"
        let g:autolinker#system_browser = "exec 'silent ! RunDll32.EXE URL.DLL,FileProtocolHandler' shellescape('%s')"
    elseif has("mac")
        let g:autolinker#system_browser = "exec 'silent !open' shellescape('%s')"
    elseif exists('$XDG_CURRENT_DESKTOP') && !empty($XDG_CURRENT_DESKTOP)
        let g:autolinker#system_browser = "exec 'silent !xdg-open' shellescape('%s') .'&'"
    elseif $GNOME_DESKTOP_SESSION_ID != "" || $DESKTOP_SESSION == 'gnome'
        let g:autolinker#system_browser = "exec 'silent !gnome-open' shellescape('%s')"
    elseif exists("$KDEDIR") && !empty($KDEDIR)
        let g:autolinker#system_browser = "exec 'silent !kfmclient exec' shellescape('%s')"
    endif
endif


if !exists('g:autolinker#cfile_gsub')
    " A list of lists [RX, SUB] that are applied to the |<cfile>| under 
    " the cursor. This can be used to rewrite filenames and URLs, in 
    " order to implement e.g. interwikis.
    let g:autolinker#cfile_gsub = []   "{{{2
endif


let s:prototype = {'fallback': g:autolinker#fallback
            \ , 'types': g:autolinker#types
            \ , 'use_highlight': g:autolinker#use_highlight
            \ , 'cfile_gsub': g:autolinker#cfile_gsub
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
endf


function! s:prototype.Highlight() abort dict "{{{3
    if !empty(self.use_highlight)
        if index(self.use_highlight, 'word')
            silent! syn clear AutoHyperlink
            let rx = join(map(values(self.defs), 'v:val.rx'), '\|')
            if !empty(rx)
                exec 'syn match AutoHyperlink /'. escape(rx, '/') .'/'
            endif
        endif
        if index(self.use_highlight, 'url')
            exec 'syn match AutoHyperlink /'. escape(g:autolinker#url_rx, '/') .'/'
        endif
        " let col = &background == 'dark' ? 'Cyan' : 'DarkBlue'
        " exec 'hi AutoHyperlink term=underline cterm=underline gui=underline ctermfg='. col 'guifg='. col
        hi AutoHyperlink term=underline cterm=underline gui=underline
    endif
endf


function! s:prototype.Edit(filename) abort dict "{{{3
    " TLogVAR a:filename
    try
        if !self.Jump_system('n', a:filename, a:filename)
            let filename = a:filename
            if isdirectory(filename)
                let index = filename .'/'. eval(g:autolinker#index)
                if filereadable(index)
                    let filename = index
                endif
            endif
            exec g:autolinker#edit fnameescape(filename)
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


function! s:prototype.CleanCWord(text) abort dict "{{{3
    return a:text
endf


function! s:prototype.CleanCFile(text) abort dict "{{{3
    let text = a:text
    if !empty(&includeexpr)
        let text = eval(substitute(&includeexpr, 'v:fname', string(a:text), 'g'))
    endif
    for [rx, sub; rest] in self.cfile_gsub
        let opts = get(rest, 0, {})
        let text = substitute(text, rx ,sub, get(opts, 'flags', 'g'))
    endfor
    return text
endf


function! s:prototype.Jump_system(mode, cword, cfile) abort dict "{{{3
    " TLogVAR a:mode, a:cword, a:cfile
    if a:cfile =~ g:autolinker#system_rx
        let cmd = printf(g:autolinker#system_browser, escape(a:cfile, ' %#!'))
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
            return self.Edit(filename)
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
    let matches = s:Globpath(&path, a:cfile .'*')
    let brx = '\C\V\%(\^\|\[\/]\)'. substitute(a:cfile, '[\/]', '\\[\\/]', 'g') .'.\[^.]\+\$'
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
        return self.Edit(filename)
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
            let fallbacks = map(split(fallback, ','), 'tlib#string#Printf1(v:val, a:cfile)')
            let fallback = tlib#input#List('s', 'Use', fallbacks)
        endif
        if !empty(fallback)
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


function! autolinker#Ensure() abort "{{{3
    if !exists('b:autolinker')
        call autolinker#EnableBuffer()
    endif
endf


let s:ft_prototypes = {}

function! autolinker#EnableBuffer() abort "{{{3
    let ft = &ft
    if !has_key(s:ft_prototypes, ft)
        let prototype = deepcopy(s:prototype)
        try
            let s:ft_prototypes[ft] = autolinker#ft_{ft}#GetInstance(prototype)
        catch /^Vim\%((\a\+)\)\=:E117/
            let s:ft_prototypes[ft] = prototype
        endtry
    endif
    let b:autolinker = copy(s:ft_prototypes[ft])
    let b:autolinker.defs = b:autolinker.WordLinks()
    call b:autolinker.Highlight()
    call b:autolinker.InstallHotkey()
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
    call autolinker#Ensure()
    if stridx('in', a:mode) != -1
        let cfile = expand("<cfile>")
        let cfile = b:autolinker.CleanCFile(cfile)
        let cword = expand("<cword>")
        let cword = b:autolinker.CleanCWord(cword)
    elseif a:mode ==# 'v'
        let cfile = @"
        let cword = cfile
    else
        throw 'AutoLinker: Unsupported mode: '. a:mode
    endif
    " TLogVAR a:mode, cfile, cword
    call s:Jump(a:mode, cfile, cword)
endf


function! s:Jump(mode, cfile, cword) abort "{{{3
    let args = [a:mode, a:cword, a:cfile]
    for type in b:autolinker.types
        let method = 'Jump_'. type
        " TLogVAR method
        if has_key(b:autolinker, method) && call(b:autolinker[method], args, b:autolinker)
            return
        endif
    endfor
    echom 'Autolinker: I can''t dance --' a:cfile
endf


function! autolinker#Edit(cfile) abort "{{{3
    call autolinker#Ensure()
    call s:Jump('n', a:cfile, a:cfile)
endf


function! autolinker#EditInPath(cfile) abort "{{{3
    let filenames = map(split(&path, ','), 'tlib#file#Join([v:val, a:cfile])')
    let filename = tlib#input#List('s', 'Select file:', filenames)
    if !empty(filename)
        exec g:autolinker#edit fnameescape(filename)
    endif
endf


