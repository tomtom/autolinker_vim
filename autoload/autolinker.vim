" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     http://github.com/tomtom/
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2015-09-26
" @Revision:    326


if !exists('g:loaded_tlib') || g:loaded_tlib < 114
    runtime plugin/tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 114
        echoerr 'tlib >= 1.14 is required'
        finish
    endif
endif


if !exists('g:autolinker#use_highlight')
    " If true, highlight potential hyperlinks.
    let g:autolinker#use_highlight = 1   "{{{2
endif


if !exists('g:autolinker#types')
    " Possible values (the order is significant):
    " - system (URLs, non-text files etc. matching 
    "   |g:autolinker#system_rx|)
    " - def (files in the current directory)
    " - path (files in 'path')
    " - tag (tags)
    " - fallback (see |g:autolinker#fallback|)
    let g:autolinker#types = ['system', 'def', 'path', 'tag', 'fallback']   "{{{2
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
    let g:autolinker#system_rx = '^\%(https\?\|nntp\|mailto\):'   "{{{2
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


function! s:Dispatch(method, default, ...) abort "{{{3
    if has_key(b:autolinker, a:method)
        return call(b:autolinker[a:method], a:000, b:autolinker)
    else
        let fn = 'autolinker#'. a:method
        if exists('*'. fn)
            return call(fn, a:000)
        else
            return a:default
        endif
    endif
endf


let s:prototype = {'fallback': g:autolinker#fallback
            \ , 'use_highlight': g:autolinker#use_highlight
            \ , 'cfile_gsub': g:autolinker#cfile_gsub
            \ }

function! s:prototype.BaseNameLinks() dict abort "{{{3
    let files = glob(self.Dirname() .'/'. get(self, 'pattern', '*'), 0, 1)
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


function! s:prototype.Edit(filename) abort dict "{{{3
    " TLogVAR a:filename
    try
        let filename = a:filename
        if isdirectory(filename)
            let index = filename .'/'. eval(g:autolinker#index)
            if filereadable(index)
                let filename = index
            endif
        endif
        exec g:autolinker#edit fnameescape(filename)
        call autolinker#Ensure()
        return 1
    catch
        echohl ErrorMsg
        echom v:exception
        echom v:throwpoint
        echohl NONE
        return 0
    endtry
endf


function! s:prototype.Jump_system(mode, cword, cfile) abort dict "{{{3
    if a:cfile =~ g:autolinker#system_rx
        let cmd = printf(g:autolinker#system_browser, a:cfile)
        exec cmd
        return 1
    else
        return 0
    endif
endf


function! s:prototype.Jump_def(mode, cword, cfile) abort dict "{{{3
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
    if has_key(self.globpath, a:cfile)
        let matches = self.globpath[a:cfile]
    else
        let matches = globpath(&path, a:cfile .'*', 0, 1)
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
        return self.Edit(filename)
    else
        return 0
    endif
endf


function! s:prototype.Jump_tag(mode, cword, cfile) abort dict "{{{3
    try
        exec 'tab' g:autolinker#tag a:cword
        return 1
    catch /^Vim\%((\a\+)\)\=:E426/
    catch /^Vim\%((\a\+)\)\=:E433/
    endtry
    return 0
endf


function! s:prototype.Jump_fallback(mode, cword, cfile) abort dict "{{{3
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


function! autolinker#InstallHotkey() abort "{{{3
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


function! autolinker#Ensure() abort "{{{3
    if !exists('b:autolinker')
        call autolinker#EnableBuffer()
    endif
endf


let s:ft_prototypes = {}

function! autolinker#EnableBuffer() abort "{{{3
    let ft = &ft
    let b:autolinker = copy(s:prototype)
    let b:autolinker.globpath = {}
    if !has_key(s:ft_prototypes, ft)
        try
            let s:ft_prototypes[ft] = autolinker#ft_{ft}#GetInstance()
        catch /^Vim\%((\a\+)\)\=:E117/
            let s:ft_prototypes[ft] = {}
        endtry
    endif
    let b:autolinker = extend(b:autolinker, s:ft_prototypes[ft])
    let defs = call(b:autolinker.BaseNameLinks, [], b:autolinker)
    let defs_ft = s:Dispatch('FiletypeLinks', {})
    if !empty(defs_ft)
        let defs = extend(defs, defs_ft)
    endif
    let b:autolinker.defs = defs
    call b:autolinker.Highlight()
    call s:Dispatch('InstallHotkey', 0)
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
        let cfile = s:Dispatch('CleanCFile', cfile, cfile)
        let cword = expand("<cword>")
        let cword = s:Dispatch('CleanCWord', cword, cword)
    elseif a:mode ==# 'v'
        let cfile = @"
        let cword = cfile
    else
        throw 'AutoLinker: Unsupported mode: '. a:mode
    endif
    " TLogVAR a:mode, cfile, cword
    let args = [a:mode, cword, cfile]
    for type in g:autolinker#types
        let method = 'Jump_'. type
        if has_key(b:autolinker, method) && call(b:autolinker[method], args, b:autolinker)
            return
        endif
    endfor
    echom 'Autolinker: I can''t dance --' cfile
endf


function! autolinker#EditInPath(cfile) abort "{{{3
    let filenames = map(split(&path, ','), 'substitute(v:val, ''[^\/]\zs$'', ''/'', ''g'') . a:cfile')
    let filename = tlib#input#List('s', 'Select file:', filenames)
    if !empty(filename)
        exec g:autolinker#edit fnameescape(filename)
    endif
endf

