" ============================================================
" http://zsaber.com/blog/p/31
" ============================================================

" global configs:
" let g:zf_no_submodule = 1
" let g:zf_no_ext = 1
" let g:zf_no_plugin = 1
" let g:zf_no_theme = 1

if 1 " global settings
    filetype plugin indent on
    syntax on
    set nocompatible

    " global functions
    function! ZF_system(cmd)
        if exists('g:ZF_system_log')
            let startTime = reltime()
            let ret = system(a:cmd)
            let costTime = float2nr(reltimefloat(reltime(startTime, reltime())) * 1000)
            call add(g:ZF_system_log, {
                        \   'cmd' : a:cmd,
                        \   'time' : costTime,
                        \ })
            return ret
        else
            return system(a:cmd)
        endif
    endfunction
    function! ZF_rm(dir)
        if g:zf_windows
            silent! call ZF_system('rmdir /s/q "' . substitute(a:dir, '/', '\', 'g') . '"')
        else
            silent! call ZF_system('rm -rf "' . substitute(a:dir, '\', '/', 'g') . '"')
        endif
    endfunction
    function! CygpathFix_absPath(path)
        if len(a:path) <= 0|return ''|endif
        if !exists('g:CygpathFix_isCygwin')
            let g:CygpathFix_isCygwin = has('win32unix') && executable('cygpath')
        endif
        let path = fnamemodify(a:path, ':p')
        if !empty(path) && g:CygpathFix_isCygwin
            if 0 " cygpath is really slow
                let path = substitute(system('cygpath -m "' . path . '"'), '[\r\n]', '', 'g')
            else
                if match(path, '^/cygdrive/') >= 0
                    let path = toupper(strpart(path, len('/cygdrive/'), 1)) . ':' . strpart(path, len('/cygdrive/') + 1)
                else
                    if !exists('g:CygpathFix_cygwinPrefix')
                        let g:CygpathFix_cygwinPrefix = substitute(system('cygpath -m /'), '[\r\n]', '', 'g')
                    endif
                    let path = g:CygpathFix_cygwinPrefix . path
                endif
            endif
        endif
        return substitute(substitute(path, '\\', '/', 'g'), '\%(\/\)\@<!\/\+$', '', '') " (?<!\/)\/+$
    endfunction

    let g:zf_vimrc_path = CygpathFix_absPath(expand('<sfile>'))

    " env
    let g:zf_windows = 0
    if (has('win32') || has('win64')) && !has('unix')
        let g:zf_windows = 1
    endif
    if has('win32unix') && executable('cygpath')
        let g:zf_cygwin = 1
    else
        let g:zf_cygwin = 0
    endif
    let g:zf_mac = 0
    if has('unix')
        try
            silent! let s:uname = ZF_system('uname')
            if match(s:uname, 'Darwin') >= 0
                let g:zf_mac = 1
            endif
        endtry
    endif
    let g:zf_linux = 0
    if has('unix')
        let g:zf_linux = 1
    endif
    if !g:zf_windows && !g:zf_mac
        let g:zf_linux = 1
    elseif g:zf_linux
        let g:zf_windows = 0
    endif

    if !exists('g:zf_fakevim')
        let g:zf_fakevim = 0
    endif

    if !exists('g:zf_githost')
        let g:zf_githost = 'https://github.com'
    endif

    if !exists('g:zf_vim_home_path')
        let g:zf_vim_home_path = CygpathFix_absPath($HOME)
    endif
    if !exists('g:zf_vim_data_path')
        let g:zf_vim_data_path = g:zf_vim_home_path . '/.vim'
    endif
    if !exists('g:zf_vim_plugin_path')
        let g:zf_vim_plugin_path = g:zf_vim_data_path . '/bundle'
    endif
    if !exists('g:zf_vim_cache_path')
        let g:zf_vim_cache_path = g:zf_vim_home_path . '/.vim_cache'
    endif
    if !isdirectory(g:zf_vim_cache_path)
        call mkdir(g:zf_vim_cache_path, 'p')
    endif
    if !exists('g:zf_vim_viminfo_path')
        if has('nvim')
            let g:zf_vim_viminfo_path = g:zf_vim_cache_path . '/viminfo_nvim'
        else
            let g:zf_vim_viminfo_path = g:zf_vim_cache_path . '/viminfo'
        endif
    endif

    " leader should be set before other key map
    if g:zf_fakevim != 1
        let mapleader = "'"
    else
        let mapleader = '\'
        map ' <leader>
    endif

    " turn on this to improve performance (especially for some low performance shell or ssh)
    if !exists('g:zf_low_performance')
        let g:zf_low_performance = !has('nvim') && !has('gui') && v:version <= 800
    endif
    augroup ZF_VimLowPerf_augroup
        autocmd!
        autocmd User ZFVimLowPerf silent
    augroup END
    function! ZF_VimLowPerfToggle()
        let g:zf_low_performance = !g:zf_low_performance
        if g:zf_low_performance
            echo 'low performance mode on'
        else
            echo 'low performance mode off'
        endif
        doautocmd User ZFVimLowPerf
    endfunction
    command! -nargs=0 ZFLowPerfToggle :call ZF_VimLowPerfToggle()

    " git info
    if !exists('g:zf_git_user_email')
        let g:zf_git_user_email = 'z@zsaber.com'
    endif
    if !exists('g:zf_git_user_name')
        let g:zf_git_user_name = 'ZSaberLv0'
    endif
    " you may set g:zf_git_user_token to git push without password
    function! ZF_GitGlobalConfig()
        call ZF_system('git config --global user.email "' . g:zf_git_user_email . '"')
        call ZF_system('git config --global user.name "' . g:zf_git_user_name . '"')
        call ZF_system('git config --global core.filemode false')
        call ZF_system('git config --global core.autocrlf false')
        call ZF_system('git config --global core.safecrlf true')
        call ZF_system('git config --global core.quotepath false')
        echo 'git global user changed to ' . g:zf_git_user_name . ' <' . g:zf_git_user_email . '>'
    endfunction
    command! -nargs=0 ZFGitGlobalConfig :call ZF_GitGlobalConfig()
endif " global settings


if 1 && !get(g:, 'zf_no_submodule', 0) " source local config before ext
    for f in sort(split(globpath(g:zf_vim_data_path . '/ZFVimModule', '*.vim'), "\n"))
        execute 'source ' . fnameescape(f)
    endfor
    for f in sort(split(globpath(g:zf_vim_data_path . '/ZFVimModule', '*/*.vim'), "\n"))
        execute 'source ' . fnameescape(f)
    endfor
endif


if 1 && !get(g:, 'zf_no_ext', 0)
    let g:zf_vimrc_ext_path = g:zf_vim_data_path . '/ZFVimModule/zf_vimrc.ext'
    if !filereadable(g:zf_vimrc_ext_path . '/README.md')
        call ZF_system('git clone --depth=1 ' . g:zf_githost . '/ZSaberLv0/zf_vimrc.ext "' . g:zf_vimrc_ext_path . '"')
    endif
    if !exists('g:ZFVimrcUtil_updateCallback')
        let g:ZFVimrcUtil_updateCallback = {}
    endif
    let g:ZFVimrcUtil_updateCallback['zf_vimrc.ext'] = 'ZF_VimrcExtUpdate'
    function! ZF_VimrcExtUpdate()
        let remote = ZF_system('cd "' . g:zf_vimrc_ext_path . '" && git remote get-url --all origin')
        let remote = substitute(remote, '[\r\n]', '', 'g')
        if match(remote, '^[a-z]\+://') < 0
            let remote = ZF_system('cd "' . g:zf_vimrc_ext_path . '" && git remote -v')
            let remote = matchstr(remote, '\%(origin[ \t]\+\)\@<=[^ \t]\+\%([ \t]\+(push)\)\@=')
            let remote = substitute(remote, '://.\+@', '://', '')
        endif
        if empty(remote) || match(remote, g:zf_githost) < 0
            call ZF_rm(g:zf_vimrc_ext_path)
            call ZF_system('git clone --depth=1 ' . g:zf_githost . '/ZSaberLv0/zf_vimrc.ext "' . g:zf_vimrc_ext_path . '"')
        else
            call ZF_system('cd "' . g:zf_vimrc_ext_path . '" && git fetch --all && git reset --hard origin/master && git pull')
        endif
    endfunction
    function! ZF_VimrcExtEdit()
        execute 'edit ' . substitute(g:zf_vimrc_ext_path, ' ', '\\ ', 'g')
    endfunction
    nnoremap <leader>vimre :call ZF_VimrcExtEdit()<cr>
endif


if 1 && !get(g:, 'zf_no_submodule', 0) " sub modules
    " extra install steps for sub modules
    let g:zfmoduleInstallerList = []
    function! ZF_ModuleInstaller(name, cmd, ...)
        if get(g:, 'ZFModule_' . a:name, get(a:, 1, 1))
            call add(g:zfmoduleInstallerList, {'name' : a:name, 'cmd' : a:cmd})
        endif
    endfunction
    function! s:ZF_ModuleInstallAction()
        if empty(g:zfmoduleInstallerList)
            echo '[ZFVimrc] no sub module to install'
            return
        endif
        for item in g:zfmoduleInstallerList
            redraw
            echo '============================================================'
            echo '[ZFVimrc] updating ' . item.name
            if type(item.cmd) == type('')
                execute '' . item.cmd
            else
                call item.cmd()
            endif
        endfor
        redraw
        echo '============================================================'
        echo '[ZFVimrc] sub module update finished'
        messages
    endfunction
    function! s:ZF_ModuleInstall()
        let moreSaved = &more
        set nomore
        let tmpfile = g:zf_vim_cache_path . '/ZFModuleInstall.log'
        silent! call delete(tmpfile)

        try
            execute 'redir > ' . tmpfile
            call s:ZF_ModuleInstallAction()
        finally
            redir END
        endtry

        enew
        execute 'edit ' . substitute(tmpfile, ' ', '\\ ', 'g')
        let &more = moreSaved
        let @/ = '.*\(zfvimrc!\|error\|fail\|unable\|exception\|not found\|ambiguous\|err!\).*'
        call histadd('/', @/)
        call feedkeys('ggn', 'nt')

        redraw!
        echo '[ZFVimrc] update finish'
    endfunction
    command! -nargs=0 ZFModuleInstall :call s:ZF_ModuleInstall()
    function! ZF_ModuleInstallFail(msg)
        echo '[ZFVimrc!] ' . a:msg
    endfunction
    function! ZF_ModuleGetApt()
        if !exists('s:ZF_ModuleGetApt')
            let s:ZF_ModuleGetApt = ''
            if !empty(globpath(substitute($PATH, ';', ',', 'g'), 'apt-cyg'))
                let s:ZF_ModuleGetApt = 'sh -c "yes | apt-cyg install \"%s\""'
            elseif executable('apt-get')
                let s:ZF_ModuleGetApt = 'yes | apt-get install "%s"'
            elseif executable('yum')
                let s:ZF_ModuleGetApt = 'yes | yum install "%s"'
            elseif executable('brew')
                let s:ZF_ModuleGetApt = 'yes | brew install "%s"'
            elseif executable('apt')
                let s:ZF_ModuleGetApt = 'yes | apt install "%s"'
            elseif executable('sh') " other special
                if !empty(globpath(substitute($PATH, g:zf_windows ? ';' : ':', ',', 'g'), 'apt-get'))
                    let s:ZF_ModuleGetApt = 'sh -c "yes | apt-get install \"%s\""'
                endif
            endif
        endif
        if empty('s:ZF_ModuleGetApt')
            call ZF_ModuleInstallFail('unable to find package manager (apt-get/yum/brew)')
        endif
        return s:ZF_ModuleGetApt
    endfunction
    function! ZF_ModuleGetPip()
        if !exists('s:ZF_ModuleGetPip')
            if executable('pip3')
                let s:ZF_ModuleGetPip = 'pip3 install "%s"'
            elseif executable('pip')
                let s:ZF_ModuleGetPip = 'pip install "%s"'
            else
                let s:ZF_ModuleGetPip = ''
            endif
        endif
        if empty('s:ZF_ModuleGetPip')
            call ZF_ModuleInstallFail('unable to find pip')
        endif
        return s:ZF_ModuleGetPip
    endfunction
    function! ZF_ModuleGetNpm()
        if !exists('s:ZF_ModuleGetNpm')
            if executable('npm')
                let s:ZF_ModuleGetNpm = 'npm install -g "%s"'
            else
                let s:ZF_ModuleGetNpm = ''
            endif
        endif
        if empty('s:ZF_ModuleGetNpm')
            call ZF_ModuleInstallFail('unable to find npm')
        endif
        return s:ZF_ModuleGetNpm
    endfunction
    function! ZF_ModuleGetGithubRelease(userName, repoName)
        if !exists('s:ZF_ModuleGetGithubRelease')
            let userName = get(g:, 'ZF_ModuleGetGithubRelease_git_user_name', get(g:, 'zf_git_user_name', ''))
            let userToken = get(g:, 'ZF_ModuleGetGithubRelease_git_user_token', get(g:, 'zf_git_user_token', ''))
            let api = 'https://api.github.com/repos/%s/%s/releases/latest'

            if executable('curl')
                let s:ZF_ModuleGetGithubRelease = 'curl'
                if !empty(userName) && !empty(userToken)
                    let s:ZF_ModuleGetGithubRelease .= printf(' --header "authorization: %s %s"', userName, userToken)
                endif
                let s:ZF_ModuleGetGithubRelease .= ' -s ' . api
            elseif executable('wget')
                let s:ZF_ModuleGetGithubRelease = 'wget'
                if !empty(userName) && !empty(userToken)
                    let s:ZF_ModuleGetGithubRelease .= printf(' --header="authorization: %s %s"', userName, userToken)
                endif
                let s:ZF_ModuleGetGithubRelease .= ' -qO- ' . api
            else
                let s:ZF_ModuleGetGithubRelease = ''
            endif

            if !empty(s:ZF_ModuleGetGithubRelease)
                let s:ZF_ModuleGetGithubRelease .= ' | grep "browser_"'
            endif
        endif
        if empty('s:ZF_ModuleGetGithubRelease')
            return []
        endif
        let list = ZF_system(printf(s:ZF_ModuleGetGithubRelease, a:userName, a:repoName))
        if match(list, 'browser_') < 0
            return []
        endif
        let ret = []
        for item in split(list, "\n")
            " http[^"]*
            call add(ret, matchstr(item, 'http[^"]*'))
        endfor
        return ret
    endfunction
    function! ZF_ModuleExecShell(cmd)
        echo a:cmd
        let msg = ZF_system(a:cmd)
        for item in split(msg, "\n")
            echo item
        endfor
        return msg
    endfunction
    function! ZF_ModuleExec(fmt, ...)
        if empty(a:fmt)
            return
        endif
        let tmp = 'let cmd = printf(a:fmt'
        if a:0 == 1 && type(a:1) == type([])
            for i in range(len(a:1))
                let tmp .= ', a:1[' . i . ']'
            endfor
        else
            for i in range(a:0)
                let tmp .= ', a:' . (i+1)
            endfor
        endif
        let tmp .= ')'
        execute tmp
        return ZF_ModuleExecShell(cmd)
    endfunction
    function! ZF_ModulePackAdd(pm, packages)
        if empty(a:pm)
            return
        endif
        for package in split(a:packages, ' ')
            call ZF_ModuleExec(a:pm, package)
        endfor
    endfunction
    function! ZF_ModuleDownloadFile(to, url)
        if !exists('s:ZF_ModuleDownloadFile')
            if executable('curl')
                let s:ZF_ModuleDownloadFile = 'curl -o "%s" -L "%s"'
                let s:ZF_ModuleDownloadFile_sizeGetter = 'curl -sI "%s"'
            elseif executable('wget')
                let s:ZF_ModuleDownloadFile = 'wget -P "%s" "%s"'
                let s:ZF_ModuleDownloadFile_sizeGetter = 'curl -sI "%s"'
            else
                let s:ZF_ModuleDownloadFile = ''
                let s:ZF_ModuleDownloadFile_sizeGetter = ''
            endif
        endif
        if empty(s:ZF_ModuleDownloadFile)
            call ZF_ModuleInstallFail('no curl or wget available')
            return 0
        endif

        let tmp = tempname()
        let to = substitute(a:to, '\\', '/', 'g')
        let parent = fnamemodify(CygpathFix_absPath(to), ':h')
        if !isdirectory(parent)
            call mkdir(parent, 'p')
        endif

        if filereadable(to)
            let existSize = getfsize(to)
            if existSize >= 0
                let remoteSize = -1
                for line in split(ZF_system(printf(s:ZF_ModuleDownloadFile_sizeGetter, a:url)), '[\r\n]')
                    if match(line, '\ccontent-length') >= 0
                        let remoteSize = str2nr(matchstr(line, '[0-9]\+'))
                        break
                    endif
                endfor
                if remoteSize == existSize
                    return 1
                endif
            endif
        endif

        let ret = ZF_system(printf(s:ZF_ModuleDownloadFile, substitute(tmp, '\\', '/', 'g'), a:url))
        if v:shell_error != 0
            call ZF_ModuleInstallFail('unable to download (' . v:shell_error . '), url: ' . a:url)
            return 0
        endif

        call writefile(readfile(tmp, 'b'), to, 'b')
        call delete(tmp)
        return 1
    endfunction
    function! ZF_ModuleGitClone(repo, toPath)
        if filereadable(a:toPath . '/.git/HEAD')
            return
        endif
        call ZF_rm(a:toPath)
        echo ZF_system('git clone --depth=1 ' . a:repo . ' "' . substitute(a:toPath, '\', '/', 'g') . '"')
    endfunction

    " steps: ZFInit, ZFPlugPrev, ZFPlugPost, ZFFinish
    function! s:subModule(step)
        for f in sort(split(globpath(g:zf_vim_data_path . '/ZFVimModule', '*/' . a:step . '/**/*.vim'), "\n"))
            execute 'source ' . fnameescape(f)
        endfor
    endfunction
    call s:subModule('ZFInit')
else
    function! ZF_ModuleInstaller(name, cmd)
    endfunction
    function! s:subModule(step)
    endfunction
endif " sub modules


" ==================================================
if 1 " custom key mapping
    " esc
    if !g:zf_fakevim
        function! ZF_Setting_ijk()
            call feedkeys((getpos('.')[2] == 1) ? "\<esc>" : "\<esc>l", 'nt')
            return ''
        endfunction
        inoremap <esc> <esc>l
        inoremap <expr> jk ZF_Setting_ijk()
        cnoremap jk <c-c>
    else
        noremap <esc> <esc>
        inoremap jk <esc>l
        cnoremap jk <esc>
    endif
    if has('terminal') || has('nvim')
        tnoremap jk <c-\><c-n>
        tnoremap <esc> <c-\><c-n>
        if has('nvim')
            command! -nargs=0 Shell :terminal
        endif
        augroup ZF_Setting_terminal
            autocmd!
            if has('nvim')
                if exists('##TermOpen')
                    autocmd TermOpen * startinsert
                    autocmd TermOpen * nnoremap <buffer><silent> q :bd!<cr>
                endif
            else
                if exists('##TerminalOpen')
                    autocmd TerminalOpen * nnoremap <buffer><silent> q :bd!<cr>
                endif
            endif
        augroup END
    endif
    if !g:zf_fakevim
        nnoremap <space> <esc>
        xnoremap <space> <esc>
        onoremap <space> <esc>
    else
        noremap <space> <esc>
    endif
    " visual
    if !g:zf_fakevim
        nnoremap V <c-v>
        xnoremap V <c-v>
        nnoremap <c-v> V
        xnoremap <c-v> V
    else
        noremap V <c-v>
        noremap <c-v> V
    endif
    " special select mode mapping
    " some plugin use vmap, which would cause unexpected behavior under select mode
    function! ZF_Setting_SelectModeMap()
        let s:_selectmode_keys = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890~!@#$%^&*-_=+\;:,./?)]}>'
        for c in split(s:_selectmode_keys, '\ze')
            silent! execute 'snoremap <silent> ' . c . ' <c-g>"_c' . c
        endfor
        let s:_selectmode_keys = '|'
        for c in split(s:_selectmode_keys, '\ze')
            let c = '\' . c
            silent! execute 'snoremap <silent> ' . c . ' <c-g>"_c' . c
        endfor
        silent! snoremap <silent> <space> <esc>
        silent! snoremap <silent> jk <esc>gv
        silent! snoremap <silent> <bs> <c-g>"_c
        silent! snoremap <silent> ( <c-g>"_c()<esc>i
        silent! snoremap <silent> [ <c-g>"_c[]<esc>i
        silent! snoremap <silent> { <c-g>"_c{}<esc>i
        silent! snoremap <silent> < <c-g>"_c<><esc>i
        silent! snoremap <silent> ' <c-g>"_c''<esc>i
        silent! snoremap <silent> " <c-g>"_c""<esc>i
        silent! snoremap <silent> ` <c-g>"_c``<esc>i
        silent! snoremap <silent> _ <c-g>"_c_<esc>a
        silent! snoremap <silent> : <c-g>"_c:<esc>a
    endfunction
    if !g:zf_fakevim
        augroup ZF_Setting_SelectModeMap_augroup
            autocmd!
            autocmd User ZFVimrcPostNormal call ZF_Setting_SelectModeMap()
        augroup END
    endif
    " scrolling
    nnoremap <c-h> zh
    nnoremap <c-l> zl
    nnoremap <c-j> <c-e>
    nnoremap <c-k> <c-y>
    imap <c-h> <left>
    imap <c-l> <right>
    imap <c-j> <down>
    imap <c-k> <up>
    cnoremap <c-h> <left>
    cnoremap <c-l> <right>
    cnoremap <c-j> <down>
    cnoremap <c-k> <up>
    nnoremap H :bp<cr>
    nnoremap L :bn<cr>
    if !g:zf_fakevim
        nnoremap J <c-f>
        xnoremap J <c-f>
        onoremap J <c-f>
        nnoremap K <c-b>
        xnoremap K <c-b>
        onoremap K <c-b>
    else
        noremap J <c-f>
        noremap K <c-b>
    endif
    " move
    if !g:zf_fakevim
        nmap z, %
        xmap z, %

        nnoremap , $
        xnoremap , $
        onoremap , $
        nnoremap g, g$
        xnoremap g, g$
        onoremap g, g$

        nnoremap j gj
        xnoremap j gj
        onoremap j gj
        nnoremap gj j
        xnoremap gj j
        onoremap gj j

        nnoremap k gk
        xnoremap k gk
        onoremap k gk
        nnoremap gk k
        xnoremap gk k
        onoremap gk k
    else
        map z, %
        noremap , $
        noremap g, $
        noremap j gj
        noremap k gk
    endif
    " brace jump
    nnoremap zg <nop>

    nnoremap zg) va)<esc>h%
    nnoremap z) va)<esc>h
    xnoremap zg) <esc>`<mz`>va)<esc>h%m>`zm<:delmarks z<cr>gv
    xnoremap z) <esc>`<mz`>va)<esc>`zm<:delmarks z<cr>gvh

    nnoremap zg] va]<esc>h%
    nnoremap z] va]<esc>h
    xnoremap zg] <esc>`<mz`>va]<esc>h%m>`zm<:delmarks z<cr>gv
    xnoremap z] <esc>`<mz`>va]<esc>`zm<:delmarks z<cr>gvh

    nnoremap zg} va}<esc>h%
    nnoremap z} va}<esc>h
    xnoremap zg} <esc>`<mz`>va}<esc>h%m>`zm<:delmarks z<cr>gv
    xnoremap z} <esc>`<mz`>va}<esc>`zm<:delmarks z<cr>gvh

    nnoremap zg> va><esc>h%
    nnoremap z> va><esc>h
    xnoremap zg> <esc>`<mz`>va><esc>h%m>`zm<:delmarks z<cr>gv
    xnoremap z> <esc>`<mz`>va><esc>`zm<:delmarks z<cr>gvh

    nnoremap zg" vi"<esc>`<h
    nnoremap z" vi"<esc>
    xnoremap zg" <esc>`<mz`>vi"<esc>`<m>`zm<:delmarks z<cr>gv
    xnoremap z" <esc>`<mz`>vi"<esc>`zm<:delmarks z<cr>gv

    nnoremap zg' vi'<esc>`<h
    nnoremap z' vi'<esc>
    xnoremap zg' <esc>`<mz`>vi'<esc>`<m>`zm<:delmarks z<cr>gv
    xnoremap z' <esc>`<mz`>vi'<esc>`zm<:delmarks z<cr>gv

    nmap zg; zg}
    nmap z; z}
    xmap zg; zg}
    xmap z; z}
    " go to define
    if !g:zf_fakevim
        if empty(mapcheck('zj', 'n'))
            nnoremap zj <c-]>
        endif
        if empty(mapcheck('zk', 'n'))
            nnoremap zk <c-t>
        endif
    else
        nnoremap zj <c-]>
        nnoremap zk <c-t>
    endif
    nnoremap zh :tprevious<cr>
    nnoremap zl :tnext<cr>
    " redo
    nnoremap U <c-r>
    " modify/delete without change clipboard
    if !g:zf_fakevim
        nnoremap c "_c
        xnoremap c "_c
        nnoremap d "_d
        xnoremap d "_d
    else
        noremap c c
        noremap d d
    endif
    nnoremap <del> "_dl
    vnoremap <del> "_d
    inoremap <del> <right><bs>
    " always use system clipboard
    if has('clipboard')
        nnoremap zp :let @" = @*<cr>:echo 'copied from system clipboard'<cr>
    else
        nnoremap zp <nop>
    endif
    " https://github.com/neovim/neovim/issues/1822
    set clipboard+=unnamed
    set clipboard+=unnamedplus
    nnoremap p gP
    xnoremap p "_dgP
    nnoremap P gp
    xnoremap P "_dgp
    nmap <c-g> p
    xmap <c-g> p
    if has('clipboard')
        inoremap <c-g> <c-r>*
        " paste as user typed
        " to ensure the command would exist in command history
        function! ZF_Setting_command_paste()
            call feedkeys("\<c-r>*", 'nt')
            return ''
        endfunction
        cnoremap <expr> <c-g> '' . ZF_Setting_command_paste()
        snoremap <c-g> <c-o>"_c<c-r>*
    else
        if !g:zf_fakevim
            inoremap <c-g> <c-r>"
            cnoremap <c-g> <c-r>"
            snoremap <c-g> <c-o>"_dgP
        else
            inoremap <c-g> <c-r>0
            cnoremap <c-g> <c-r>0
            snoremap <c-g> <c-o>"_c<c-r>0
        endif
    endif
    if has('clipboard')
        cnoremap <s-insert> <c-r>*
    else
        cnoremap <s-insert> <c-r>"
    endif
    " window and buffer management
    nnoremap B :bufdo<space>
    nnoremap zs :w<cr>
    nnoremap ZS :wa<cr>
    nnoremap zx :w<cr>:bd<cr>
    nnoremap ZX :wa<cr>:bufdo bd<cr>
    nnoremap cx :bd!<cr>
    nnoremap CX :bufdo bd!<cr>
    if !g:zf_fakevim
        nnoremap x :bd<cr>
    else
        nnoremap x :q<cr>
    endif
    command! W w !sudo tee % > /dev/null

    nnoremap WH <c-w>h
    nnoremap WL <c-w>l
    nnoremap WJ <c-w>j
    nnoremap WK <c-w>k

    nnoremap WO :resize<cr>:vertical resize<cr>
    nnoremap WI :vertical resize<cr>
    nnoremap WU :resize<cr>
    nnoremap WW <c-w>w
    nnoremap WN <c-w>=
    nnoremap Wh 30<c-w><
    nnoremap Wl 30<c-w>>
    nnoremap Wj 10<c-w>+
    nnoremap Wk 10<c-w>-
    " fold
    xnoremap ZH zf
    nnoremap ZH zc
    nnoremap ZL zo
    nnoremap Zh zC
    nnoremap Zl zO
    nnoremap ZU zE
    nnoremap ZI zM
    nnoremap ZO zR
    " diff util
    nnoremap D <nop>
    nnoremap DJ ]czz
    nnoremap DK [czz
    nnoremap DH do
    xnoremap DH :diffget<cr>
    nnoremap DL dp
    xnoremap DL :diffput<cr>
    nnoremap DD :diffupdate<cr>
    " quick move lines
    nnoremap C <nop>

    if !g:zf_fakevim
        nnoremap CH v"txhh"tp
        nnoremap CL v"tx"tp
        nnoremap CJ mT:m+<cr>`T:delmarks T<cr>:echo ''<cr>
        nnoremap CK mT:m-2<cr>`T:delmarks T<cr>:echo ''<cr>

        xnoremap CH "txhh"tp`<hm<`>hm>gv
        xnoremap CL "tx"tp`<lm<`>lm>gv
        xnoremap CJ :m'>+<cr>gv
        xnoremap CK :m'<-2<cr>gv
    else
        nnoremap CH vxhhp
        nnoremap CL vxp
        nnoremap CJ :m+<cr>
        nnoremap CK :m-2<cr>

        vnoremap CH xhhp`<hm<`>hm>gv
        vnoremap CL xp`<lm<`>lm>gv
        vnoremap CJ :m'>+<cr>gv
        vnoremap CK :m'<-2<cr>gv
    endif

    nnoremap < <<
    nnoremap > >>
    " inc/dec numbers
    nnoremap CI <c-a>
    nnoremap CU <c-x>
    set nrformats+=alpha
    set nrformats-=octal
    " macro spec
    function! ZF_Setting_VimMacroMap()
        nnoremap Q :call ZF_Setting_VimMacroBegin(0)<cr>
        nnoremap zQ :call ZF_Setting_VimMacroBegin(1)<cr>
        nnoremap cQ :let @t = 'let @m="' . @m . '"'<cr>q:"tgP
        nmap M @m
    endfunction
    function! ZF_Setting_VimMacroBegin(isAppend)
        nnoremap Q q:call ZF_Setting_VimMacroEnd()<cr>
        nnoremap M q:call ZF_Setting_VimMacroEnd()<cr>@m
        if !a:isAppend
            normal! qm
        else
            normal! qM
        endif
    endfunction
    function! ZF_Setting_VimMacroEnd()
        call ZF_Setting_VimMacroMap()
        echo 'macro recorded, use M in normal mode to repeat'
    endfunction
    if !g:zf_fakevim
        " mapping '::' would confuse some vim simulate plugins which would cause strange behavior,
        " even worse, some of them won't check 'if' statement and always apply settings inside the 'if',
        " here's some tricks (using autocmd) to completely prevent the mapping from being executed
        augroup ZF_Setting_VimMacro_augroup
            autocmd!
            autocmd User ZFVimrcPostNormal
                        \  call ZF_Setting_VimMacroMap()
                        \| nnoremap :: q:k$
                        \| nnoremap // q/k$
        augroup END
    endif
    " quick edit command
    function! ZF_Setting_cmdEdit()
        let cmdtype = getcmdtype()
        if cmdtype != ':' && cmdtype != '/'
            return ''
        endif
        call feedkeys("\<c-c>q" . cmdtype . 'k0' . (getcmdpos() - 1) . 'l', 'nt')
        return ''
    endfunction
    cnoremap <silent><expr> ;; ZF_Setting_cmdEdit()
    " search and replace
    " (here's a memo for regexp)
    "
    " zero width:
    "     (?=exp)  : anything end with exp (excluding exp)
    "     (?!exp)  : anything not end with exp
    "     (?<=exp) : anything start with exp (excluding exp)
    "     (?<!exp) : anything not start with exp
    "
    " match as less as possible:
    "     .*    : .*?
    "     .+    : .+?
    "     .{n,} : .{n,}?
    "
    " match line except contains zzz:
    "     ^(?!.*zzz).*$
    if !g:zf_fakevim
        nnoremap / /\v
        nnoremap ? /\v
        nnoremap <leader>vr :.,$s/\v/gec<left><left><left><left>
        xnoremap <leader>vr "ty:.,$s/\v<c-r>t//gec<left><left><left><left>
        nnoremap <leader>zr :.,$s/\v/gec<left><left><left><left><<c-r><c-w>>/
        xnoremap <leader>zr "ty:.,$s/\v<<c-r>t>//gec<left><left><left><left>

        nnoremap <leader>v/ :%s/\v//gn<left><left><left><left>
        xnoremap <leader>v/ "ty:%s/\v<c-r>t//gn<left><left><left><left>
        nnoremap <leader>z/ :%s/\v<<c-r>t>//gn<left><left><left><left>
        xnoremap <leader>z/ "ty:%s/\v<<c-r>t>//gn<left><left><left><left>
    else
        nnoremap / /
        nnoremap ? /
        nnoremap <leader>vr :.,$s//gec<left><left><left><left>
        vnoremap <leader>vr y:.,$s/<c-r>0//gec<left><left><left><left>
        nnoremap <leader>zr :.,$s//gec<left><left><left><left>\<<c-r><c-w>\>/
        vnoremap <leader>zr y:.,$s/\<<c-r>0\>//gec<left><left><left><left>

        nnoremap <leader>v/ :%s///gn<left><left><left><left>
        xnoremap <leader>v/ y:%s/<c-r>0//gn<left><left><left><left>
        nnoremap <leader>z/ :%s/\<<c-r>0\>//gn<left><left><left><left>
        xnoremap <leader>z/ y:%s/\<<c-r>0\>//gn<left><left><left><left>
    endif
    " command line utils
    cnoremap <expr> %% getcmdtype() == ':' ? substitute(expand('%:p'), '\\', '/', 'g') : '%%'
    " suspend is not useful and would confuse user
    nnoremap <c-z> <nop>
endif " custom key mapping


" ==================================================
if 1 " common settings
    " common
    if !empty(g:zf_vim_viminfo_path)
        let zf_vim_viminfo_path = substitute(substitute(g:zf_vim_viminfo_path, '\\', '/', 'g'), ' ', '\\ ', 'g')
        if has('viminfo')
            if exists('&viminfofile')
                execute 'set viminfofile=' . zf_vim_viminfo_path
            else
                execute 'set viminfo+=n' . zf_vim_viminfo_path
            endif
        elseif exists('&shada')
            execute 'set shada+=n' . zf_vim_viminfo_path
        endif
    endif
    set hidden
    set list
    set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
    set modeline
    silent! set shortmess+=F
    set showcmd
    set showmatch
    set wildmenu
    set autoread
    set nobackup
    set nowritebackup
    set noswapfile
    set nowrap
    set synmaxcol=200
    set lazyredraw
    set guioptions=gtk
    set whichwrap=b,s,<,>,[,]
    set display=lastline
    set sessionoptions-=options
    " https://github.com/vim/vim/issues/13721
    set ttimeoutlen=50
    if has("patch-8.1.1564")
        set signcolumn=number
    endif
    function! ZF_Setting_common_action()
        set number
        set textwidth=0
        set iskeyword=@,48-57,_,128-167,224-235
    endfunction
    call ZF_Setting_common_action()
    augroup ZF_Setting_common_augroup
        autocmd!
        autocmd FileType,BufNewFile,BufReadPost * call ZF_Setting_common_action()
    augroup END
    function! ZF_Setting_isLargeFile(file)
        if get(b:, 'zf_vim_largefile_force', 0)
            return 1
        endif
        try
            let size = getfsize(a:file)
            let largeFile = get(g:, 'ZF_Setting_largefile', 2 * 1024 * 1024)
            if size == -2 || (largeFile > 0 && size > largeFile)
                return 1
            endif
            let largeColumn = get(g:, 'ZF_Setting_largefile_column', 2000)
            if largeColumn > 0 && filereadable(a:file)
                for line in readfile(a:file, '', get(g:, 'ZF_Setting_largefile_columnChecklines', 20))
                    if len(line) >= largeColumn
                        return 1
                    endif
                endfor
            endif
        catch
        endtry
        return 0
    endfunction
    augroup ZF_Setting_largefile_augroup
        autocmd!
        function! s:ZF_Setting_largefile_restore(...)
            set eventignore-=FileType
        endfunction
        function! s:ZF_Setting_largefile_setup(notifyRestore)
            if !get(b:, 'zf_vim_largefile', 0) && ZF_Setting_isLargeFile(expand('<afile>'))
                set eventignore+=FileType
                if has('timers')
                    call timer_start(1, function('s:ZF_Setting_largefile_restore'))
                endif
                " unload would cause buffer reload when enter again,
                " would save some memory but not handy for general usage
                " setlocal bufhidden=unload
                let b:zf_vim_largefile_saved_foldmethod=&foldmethod
                setlocal foldmethod=manual
                let b:zf_vim_largefile_saved_foldenable=&foldenable
                setlocal nofoldenable
                let b:zf_vim_largefile_saved_swapfile=&swapfile
                setlocal noswapfile
                let b:zf_vim_largefile_saved_cursorline=&cursorline
                setlocal nocursorline
                let b:zf_vim_largefile_saved_cursorcolumn=&cursorcolumn
                setlocal nocursorcolumn
                let b:zf_vim_largefile_saved_relativenumber=&relativenumber
                setlocal norelativenumber
                let b:zf_vim_largefile = 1
                doautocmd User ZFVimLargeFile
            elseif get(b:, 'zf_vim_largefile', 0) && a:notifyRestore
                let b:zf_vim_largefile = 0
                if exists('b:zf_vim_largefile_saved_foldmethod')
                    execute 'setlocal foldmethod=' . b:zf_vim_largefile_saved_foldmethod
                    unlet b:zf_vim_largefile_saved_foldmethod
                endif
                if get(b:, 'zf_vim_largefile_saved_foldenable', 0)
                    set foldenable
                endif
                if get(b:, 'zf_vim_largefile_saved_swapfile', 0)
                    set swapfile
                endif
                if get(b:, 'zf_vim_largefile_saved_cursorline', 0)
                    set cursorline
                endif
                if get(b:, 'zf_vim_largefile_saved_cursorcolumn', 0)
                    set cursorcolumn
                endif
                if get(b:, 'zf_vim_largefile_saved_relativenumber', 0)
                    set relativenumber
                endif
                doautocmd User ZFVimLargeFile
            endif
        endfunction
        autocmd User ZFVimLargeFile silent
        autocmd BufReadPre,BufCreate * call s:ZF_Setting_largefile_setup(0)
        autocmd BufWritePost * call s:ZF_Setting_largefile_setup(1)
    augroup END
    " encodings
    set fileformats=unix,dos
    set fileformat=unix
    set encoding=utf-8
    set fileencoding=utf-8
    set fileencodings=utf-8,ucs-bom,chinese,sjis
    " search
    set ignorecase
    set smartcase
    set hlsearch
    set incsearch
    let s:ZF_Setting_ToggleSearch_last = ''
    function! ZF_Setting_ToggleSearch()
        if s:ZF_Setting_ToggleSearch_last == '' || s:ZF_Setting_ToggleSearch_last == @/
            let s:ZF_Setting_ToggleSearch_last = @/
            echo '' . s:ZF_Setting_ToggleSearch_last
            return
        endif

        echo 'choose search pattern:'
        echo '  j: ' . s:ZF_Setting_ToggleSearch_last
        echo '  k: ' . @/
        let confirm = nr2char(getchar())
        redraw!

        if confirm == 'j'
            let @/ = s:ZF_Setting_ToggleSearch_last
            silent! normal! n
            echo '' . @/
        elseif confirm == 'k'
            let s:ZF_Setting_ToggleSearch_last = @/
            silent! normal! n
            echo '' . @/
        else
            echo 'canceled'
        endif
    endfunction
    nnoremap zb :call ZF_Setting_ToggleSearch()<cr>

    if !g:zf_fakevim
        nnoremap zn viw"ty/<c-r>t<cr>N
        xnoremap zn "ty/<c-r>t<cr>N
        nnoremap zm viw"ty/\<<c-r>t\><cr>N
        xnoremap zm "ty/\<<c-r>t\><cr>N
    else
        nnoremap zn viwy/<c-r>0<cr>N
        xnoremap zn y/<c-r>0<cr>N
        nnoremap zm viwy/\<<c-r>0\><cr>N
        xnoremap zm y/\<<c-r>0\><cr>N
    endif
    " tab and indent
    set expandtab
    set nosmarttab
    set smartindent
    set cindent
    set cinoptions=l1,g0,(2s,w1s,W1s,M1,j1,J1
    set autoindent
    function! s:tabstop(tabstop)
        let b:tabstop = a:tabstop
        let s:tabstopOverride=1
        let &shiftwidth = a:tabstop
        let &tabstop = a:tabstop
        let &softtabstop = 0
        let s:tabstopOverride=0
    endfunction
    function! s:tabstopInit()
        if !exists('b:tabstop')
            call s:tabstop(4)
        endif
    endfunction
    augroup ZF_Setting_tabstopInit_augroup
        autocmd!
        autocmd BufEnter * call s:tabstopInit()
    augroup END
    if exists('##OptionSet')
        augroup ZF_Setting_tabstopSync_augroup
            autocmd!
            autocmd OptionSet shiftwidth,tabstop,softtabstop call s:tabstopSync()
        augroup END
        function! s:tabstopSync()
            if get(s:, 'tabstopOverride', 0)
                        \ || v:option_new <= 0
                return
            endif
            call s:tabstop(v:option_new)
        endfunction
    endif
    " editing
    set virtualedit=onemore,block
    " exclusive is buggy, especially for old plugins
    " set selection=exclusive
    set guicursor=a:block-blinkon0
    set backspace=indent,eol,start
    set scrolloff=5
    set nostartofline
    set sidescrolloff=5
    set selectmode=key
    set mouse=
    set nomodeline
    " disable italic fonts
    if v:version > 704 && get(g:, 'ZF_Setting_disableItalic', 0)
        function! ZF_Setting_disableItalic()
            let his = ''
            if exists('*execute')
                let his = execute('highlight')
            else
                try
                    redir => his
                    silent highlight
                finally
                    redir END
                endtry
            endif
            let his = substitute(his, '\n\s\+', ' ', 'g')
            for line in split(his, "\n")
                if line !~ ' links to ' && line !~ ' cleared$' && line =~ 'italic'
                    execute 'hi' substitute(substitute(line, ' xxx ', ' ', ''), 'italic', 'none', 'g')
                endif
            endfor
        endfunction
        function! ZF_Setting_disableItalic_auto()
            if g:zf_low_performance
                augroup ZF_Setting_disableItalic_auto_augroup
                    autocmd!
                augroup END
            else
                silent! call ZF_Setting_disableItalic()
                augroup ZF_Setting_disableItalic_auto_augroup
                    autocmd!
                    autocmd FileType,BufNewFile,BufReadPost * silent! call ZF_Setting_disableItalic()
                augroup END
            endif
        endfunction
        call ZF_Setting_disableItalic_auto()
        augroup ZF_Setting_disableItalic_augroup
            autocmd!
            autocmd User ZFVimLowPerf call ZF_Setting_disableItalic_auto()
        augroup END
    endif
    " status line
    set laststatus=2
    let &statusline='%<%f %m%r%=%k %l/%L : %c   %y [%{(&bomb?",BOM ":"")}%{(&fenc=="")?&enc:&fenc} %{(&fileformat)}] %4b %04B %3p%%'
    augroup ZF_Setting_quickfix_statusline_augroup
        autocmd!
        autocmd BufWinEnter quickfix,qf
                    \ let &l:statusline='%<%t %=%k %l/%L : %c %4b %04B %3p%%'
    augroup END
    " cursorline
    set linespace=2
    augroup ZF_Setting_cursorline_augroup
        autocmd!
        autocmd User ZFVimLowPerf,ZFVimrcPostLow
                    \ let &cursorline = !g:zf_low_performance
    augroup END
    " complete
    if !g:zf_fakevim
        inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<cr>"
        inoremap <expr> <c-p> pumvisible()
                    \ ? '<c-p>'
                    \ : '<c-p><c-r>=pumvisible() && match(&completeopt, "longest") >= 0 ? "\<lt>Up>" : ""<cr>'
        inoremap <expr> <c-n> pumvisible()
                    \ ? '<c-n>'
                    \ : '<c-n><c-r>=pumvisible() && match(&completeopt, "longest") >= 0 ? "\<lt>Down>" : ""<cr>'
        inoremap <expr> <c-k> pumvisible() ? '<c-p>' : '<up>'
        inoremap <expr> <c-j> pumvisible() ? '<c-n>' : '<down>'
        inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
        inoremap <expr><s-tab> pumvisible() ? "\<c-p>" : "\<s-tab>"
    else
        inoremap <cr> <cr>
        inoremap <c-p> <c-p>
        inoremap <c-n> <c-n>
        inoremap <c-k> <c-k>
        inoremap <c-j> <c-j>
        inoremap <tab> <tab>
        inoremap <s-tab> <s-tab>
    endif
    set completeopt=menuone
    set complete=.,w,b,u,k,t
    set omnifunc=syntaxcomplete#Complete
    " fold
    function! ZF_Setting_fold_action()
        set foldminlines=0
        set foldlevel=128
        set foldignore=
        set foldmethod=manual
        normal! zE
    endfunction
    call ZF_Setting_fold_action()
    augroup ZF_Setting_fold_augroup
        autocmd!
        autocmd FileType,BufNewFile,BufReadPost * call ZF_Setting_fold_action()
    augroup END
    " diff
    set diffopt=filler,context:200
    " q
    if !g:zf_fakevim
        nnoremap q <esc>
        xnoremap q <esc>
        onoremap q <esc>
    else
        noremap q <esc>
    endif
    augroup ZF_Setting_qToEsc_augroup
        autocmd!
        autocmd CmdwinEnter *
                    \ nnoremap <buffer> <silent> q :q<cr>
        autocmd BufWinEnter quickfix,qf
                    \  nnoremap <buffer> <silent> q :bd<cr>
                    \| nnoremap <buffer> <silent> <leader>vt :bd<cr>
                    \| nnoremap <buffer> <silent> <cr> <cr>:lclose<cr>
                    \| nnoremap <buffer> <silent> o <cr>:lclose<cr>
                    \| setlocal foldmethod=indent
        autocmd FileType help
                    \ nnoremap <buffer> <silent> q :q<cr>
    augroup END
endif " common settings


" ============================================================
" all plugins
"     vim-plug
"     git clone --depth=1 https://github.com/junegunn/vim-plug ~/.vim/bundle/vim-plug
if 1 && !get(g:, 'zf_no_plugin', 0)
    " ==================================================
    " plug setting
    let g:plug_home = g:zf_vim_plugin_path
    let g:plug_url_format = g:zf_githost . '/%s'
    let s:plug_file_path = g:zf_vim_plugin_path . '/vim-plug/plug.vim'

    " ==================================================
    " plug auto install
    let g:zfplugMap = {}
    let g:zfplug_needupdate = 0
    function! s:Plug(repo, ...)
        if get(get(g:, 'zfplugDisableMap', {}), a:repo, 0)
            return
        endif
        if get(g:zfplugMap, a:repo) != 0
            return
        endif
        if a:0 > 0
            Plug a:repo, a:1
        else
            Plug a:repo
        endif
        let g:zfplugMap[a:repo] = 1
        let repoName = fnamemodify(a:repo, ':t:s?\.git$??')
        let repoDir = get(get(a:, 1, {}), 'dir', g:zf_vim_plugin_path . '/' . repoName)
        if !isdirectory(repoDir)
            let g:zfplug_needupdate = 1
        endif
    endfunction
    command! -nargs=+ -bar ZFPlug call s:Plug(<args>)
    function! s:PlugCheck()
        if g:zfplug_needupdate
            let g:zfplug_needupdate = 0
            let g:ZFVimrcUtil_AutoUpdateOverride = 1
            if exists(':PlugInstall')
                PlugInstall
            endif
        endif
    endfunction

    if !filereadable(s:plug_file_path)
        call ZF_system('git clone --depth=1 ' . g:zf_githost . '/junegunn/vim-plug "' . g:zf_vim_plugin_path . '/vim-plug"')
    endif

    " minimal plugin config:
    "     filetype plugin indent on
    "     syntax on
    "     set nocompatible
    "     let g:plug_home = $HOME . '/.vim/bundle'
    "     let g:plug_url_format = 'https://github.com/%s'
    "     execute 'source ' . g:plug_home . '/vim-plug/plug.vim'
    "     silent! call plug#begin()
    "     Plug 'junegunn/vim-plug'
    "     call plug#end()
    execute 'source ' . s:plug_file_path
    silent! call plug#begin()
    ZFPlug 'junegunn/vim-plug'
    call s:subModule('ZFPlugPrev')

    " ==================================================
    if 1 && !get(g:, 'zf_no_theme', 0) " themes
        " ==================================================
        " let g:zf_color_plugin_(256|default) = 'YourSchemePlugin'
        " let g:zf_color_name_(256|default) = 'YourSchemeName'
        " let g:zf_color_bg_(256|default) = 'dark_or_light'
        if !exists('g:zf_color_plugin_default')
            let g:zf_color_plugin_default = 'vim-scripts/xterm16.vim'
            let xterm16_brightness = 'high'
            let xterm16_colormap = 'soft'
        endif
        if !exists('g:zf_color_name_default')
            let g:zf_color_name_default = 'xterm16'
        endif
        if !exists('g:zf_color_bg_default')
            let g:zf_color_bg_default = 'dark'
        endif

        if !empty('g:zf_color_plugin_default')
            ZFPlug g:zf_color_plugin_default
        endif

        " ==================================================
        if !exists('g:zf_color_plugin_256')
            let g:zf_color_plugin_256 = 'morhetz/gruvbox'
            let g:gruvbox_italic = 0
            function! ZF_Plugin_gruvbox_colorscheme()
                if get(g:, 'ZF_colorscheme_override', 1)
                    highlight Cursor gui=BOLD guibg=Green guifg=Black
                    highlight Cursor cterm=BOLD ctermbg=Green ctermfg=Black
                    highlight CursorLine gui=UNDERLINE guibg=NONE guifg=NONE
                    highlight CursorLine cterm=BOLD ctermbg=NONE ctermfg=NONE
                endif
            endfunction
            augroup ZF_Plugin_gruvbox_augroup
                autocmd!
                autocmd User ZFVimrcColorscheme call ZF_Plugin_gruvbox_colorscheme()
            augroup END
        endif
        if !exists('g:zf_color_name_256')
            let g:zf_color_name_256 = 'gruvbox'
        endif
        if !exists('g:zf_color_bg_256')
            let g:zf_color_bg_256 = g:zf_color_bg_default
        endif

        if !exists('g:zf_colorscheme_256')
            let g:zf_colorscheme_256 = 1
        endif
        if g:zf_colorscheme_256 == 1 && !has('gui') && substitute(ZF_system('tput colors'), "[\r\n]", '', 'g') < 256
            let g:zf_colorscheme_256 = 0
        endif
        if g:zf_colorscheme_256 == 1
            set t_Co=256
            if g:zf_color_plugin_256 != '' && g:zf_color_plugin_256 != g:zf_color_plugin_default
                ZFPlug g:zf_color_plugin_256
            endif
            execute 'set background=' . g:zf_color_bg_256
        else
            execute 'set background=' . g:zf_color_bg_default
        endif
    endif " themes

    " ==================================================
    if 1 " common plugins for happy text editing
        " ==================================================
        if !exists('g:ZF_Plugin_agit')
            let g:ZF_Plugin_agit = 1
        endif
        if v:version < 704
            let g:ZF_Plugin_agit = 0
        endif
        if g:ZF_Plugin_agit
            ZFPlug 'cohama/agit.vim'
            ZFPlug 'ZSaberLv0/agit.vim.config'
            command! -nargs=* -complete=dir ZFGitDiff :call AGIT_main(<q-args>)
            command! -nargs=* -complete=file ZFGitDiffFile :call AGIT_file(<q-args>)
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_auto_mkdir')
            let g:ZF_Plugin_auto_mkdir = 1
        endif
        if g:ZF_Plugin_auto_mkdir
            ZFPlug 'DataWraith/auto_mkdir'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_auto_pairs')
            let g:ZF_Plugin_auto_pairs = 1
        endif
        if g:ZF_Plugin_auto_pairs
            ZFPlug 'jiangmiao/auto-pairs'
            let g:AutoPairsShortcutToggle = ''
            let g:AutoPairsShortcutFastWrap = ''
            let g:AutoPairsShortcutJump = ''
            let g:AutoPairsShortcutBackInsert = ''
            let g:AutoPairsCenterLine = 0
            let g:AutoPairsMultilineClose = 0
            let g:AutoPairsMapBS = 1
            let g:AutoPairsMapCh = 0
            let g:AutoPairsMapCR = 0
            let g:AutoPairsMapSpace = 0
            let g:AutoPairsFlyMode = 0
            let g:AutoPairsMultilineClose = 0
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_BufOnly')
            let g:ZF_Plugin_BufOnly = 1
        endif
        if g:ZF_Plugin_BufOnly
            ZFPlug 'vim-scripts/BufOnly.vim'
            nnoremap X :BufOnly<cr>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_buftabline')
            let g:ZF_Plugin_buftabline = 1
        endif
        if g:ZF_Plugin_buftabline
            ZFPlug 'ap/vim-buftabline'
            let g:buftabline_numbers = 1
            let g:buftabline_indicators = 1
            let g:buftabline_plug_max = 0
            function! ZF_Plugin_buftabline_colorscheme()
                if get(g:, 'ZF_colorscheme_override', 1) && get(g:, 'ZF_colorscheme_override_buftabline', 1)
                    highlight BufTabLineCurrent gui=bold guibg=LightGreen guifg=Black
                    highlight BufTabLineCurrent cterm=bold ctermbg=LightGreen ctermfg=Black
                    highlight BufTabLineActive gui=BOLD guibg=WHITE guifg=BLACK
                    highlight BufTabLineActive cterm=BOLD ctermbg=White ctermfg=Black
                    highlight BufTabLineHidden gui=BOLD guibg=WHITE guifg=BLACK
                    highlight BufTabLineHidden cterm=BOLD ctermbg=White ctermfg=Black
                    highlight BufTabLineFill gui=BOLD guibg=WHITE guifg=BLACK
                    highlight BufTabLineFill cterm=BOLD ctermbg=White ctermfg=Black
                endif
            endfunction
            augroup ZF_Plugin_buftabline_augroup
                autocmd!
                autocmd User ZFVimrcColorscheme call ZF_Plugin_buftabline_colorscheme()
            augroup END
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_CmdlineComplete')
            let g:ZF_Plugin_CmdlineComplete = 1
        endif
        if g:ZF_Plugin_CmdlineComplete
            ZFPlug 'vim-scripts/CmdlineComplete'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_diff_enhanced')
            let g:ZF_Plugin_diff_enhanced = 1
        endif
        if g:ZF_Plugin_diff_enhanced
            try
                set diffopt+=internal,algorithm:patience
            catch
                if v:version > 704
                    ZFPlug 'chrisbra/vim-diff-enhanced'
                    let &diffexpr = 'EnhancedDiff#Diff("git diff", "--diff-algorithm=patience")'
                endif
            endtry
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_easy_align')
            let g:ZF_Plugin_easy_align = 1
        endif
        if g:ZF_Plugin_easy_align
            ZFPlug 'junegunn/vim-easy-align'
            let g:easy_align_ignore_groups = []
            function! ZF_Plugin_EasyAlign_regexFix(param)
                let param = substitute(a:param, '/', '_zf_slash_', 'g')
                let param = substitute(a:param, '\\', '_zf_bslash_', 'g')
                let head = matchstr(a:param, '^[^/]*/')
                let tail = matchstr(a:param, '/[^/]*$')
                if empty(head) || empty(tail)
                    return a:param
                endif
                let regexp = strpart(param, len(head), len(param) - len(head) - len(tail))
                let regexp = substitute(regexp, '^\v', '', 'g')
                try
                    let regexp = E2v(regexp)
                catch
                    return a:param
                endtry
                let param = head . regexp . tail
                let param = substitute(param, '_zf_slash_', '/', 'g')
                let param = substitute(param, '_zf_bslash_', '\\', 'g')
                return param
            endfunction
            command! -nargs=* -range -bang ZFEasyAlign <line1>,<line2>call easy_align#align(<bang>0, 0, 'command', ZF_Plugin_EasyAlign_regexFix(<q-args>))
            xnoremap <leader>ca :ZFEasyAlign */\v/l0r0>al<left><left><left><left><left><left><left><left>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_easygrep')
            let g:ZF_Plugin_easygrep = 1
        endif
        if g:ZF_Plugin_easygrep
            set grepprg=grep\ -n\ $*\ /dev/null
            " ZFPlug 'dkprice/vim-easygrep'
            " modified to support:
            " * `--exclude-from` with large exclude list
            ZFPlug 'ZSaberLv0/vim-easygrep'
            let g:EasyGrepCommand = 1
            let g:EasyGrepPerlStyle = 1
            let g:EasyGrepRecursive = 1
            let g:EasyGrepHidden = 0
            let g:EasyGrepAllOptionsInExplorer = 1
            let g:EasyGrepReplaceWindowMode = 2
            let g:EasyGrepDisableCmdParam = 1
            function! ZF_Plugin_easygrep_install()
                call ZF_ModulePackAdd(ZF_ModuleGetApt(), 'grep')
            endfunction
            call ZF_ModuleInstaller('ZF_Plugin_easygrep', 'call ZF_Plugin_easygrep_install()')

            function! ZF_Plugin_easygrep_extraOpts(opts)
                let ret = a:opts
                let exclude = ZFIgnoreGet()
                if match(ZF_system('grep --version'), 'GNU') >= 0
                    if !empty(exclude['file'])
                        let s:easygrep_excludeFile = tempname()
                        call writefile(exclude['file'], s:easygrep_excludeFile)
                        let ret .= ' --exclude-from="' . substitute(s:easygrep_excludeFile, '\\', '/', 'g') . '"'
                    endif
                else
                    let ret .= ' --exclude="' . join(exclude['file'], '" --exclude="') . '"'
                endif
                if !empty(exclude['dir'])
                    let ret .= ' --exclude-dir="' . join(exclude['dir'], '" --exclude-dir="') . '"'
                endif
                return ret . ' '
            endfunction
            let g:EasyGrepCommandExtraOpts = 'ZF_Plugin_easygrep_extraOpts'
            let g:EasyGrepFilesToExclude = ''

            " ugly workaround to prevent default keymap
            let g:EasyGrepOptionPrefix = '<leader>v?grep?y'
            map <silent> <leader>v?grep?v <plug>EgMapGrepCurrentWord_v
            xmap <silent> <leader>v?grep?v <plug>EgMapGrepSelection_v
            map <silent> <leader>v?grep?V <plug>EgMapGrepCurrentWord_V
            xmap <silent> <leader>v?grep?V <plug>EgMapGrepSelection_V
            map <silent> <leader>v?grep?a <plug>EgMapGrepCurrentWord_a
            xmap <silent> <leader>v?grep?a <plug>EgMapGrepSelection_a
            map <silent> <leader>v?grep?A <plug>EgMapGrepCurrentWord_A
            xmap <silent> <leader>v?grep?A <plug>EgMapGrepSelection_A
            map <silent> <leader>v?grep?r <plug>EgMapReplaceCurrentWord_r
            xmap <silent> <leader>v?grep?r <plug>EgMapReplaceSelection_r
            map <silent> <leader>v?grep?R <plug>EgMapReplaceCurrentWord_R
            xmap <silent> <leader>v?grep?R <plug>EgMapReplaceSelection_R

            " ugly workaround to support `ggrep` in Mac
            function! s:fix_ggrep()
                if exists('s:fix_ggrep_flag')
                    return
                endif
                let s:fix_ggrep_flag = 1
                if !executable('ggrep')
                    return
                endif
                if exists('*exepath')
                    let ggrep = exepath('ggrep')
                else
                    let ggrep = get(split(globpath(join(split($PATH, ':'), ','), 'ggrep'), "\n"), 0, '')
                endif
                if empty(ggrep)
                    return
                endif
                let tmpDir = 'easygrep_ggrep_fix'
                if !filereadable(g:zf_vim_cache_path . '/' . tmpDir . '/grep')
                    call mkdir(g:zf_vim_cache_path . '/' . tmpDir, 'p')
                    call ZF_system('ln -s "' . ggrep . '" "' . g:zf_vim_cache_path . '/' . tmpDir . '/grep"')
                endif
                if match($PATH, tmpDir) < 0
                    if empty($PATH)
                        let $PATH=g:zf_vim_cache_path . '/' . tmpDir
                    else
                        let $PATH=g:zf_vim_cache_path . '/' . tmpDir . ':' . $PATH
                    endif
                endif
            endfunction

            function! ZF_Plugin_easygrep_Grep(arg)
                call s:fix_ggrep()
                execute ':Grep ' . a:arg
                execute ':silent! M/' . a:arg
                if exists('s:easygrep_excludeFile')
                    call delete(s:easygrep_excludeFile)
                    unlet s:easygrep_excludeFile
                endif
            endfunction
            command! -nargs=+ ZFGrep :call ZF_Plugin_easygrep_Grep(<q-args>)
            nnoremap <leader>vgf :ZFGrep<space>
            function! ZF_Plugin_easygrep_Replace(arg)
                call s:fix_ggrep()
                filetype off
                execute ':Replace ' . a:arg
                filetype on
                if exists('s:easygrep_excludeFile')
                    call delete(s:easygrep_excludeFile)
                    unlet s:easygrep_excludeFile
                endif
            endfunction
            command! -nargs=+ ZFReplace :call ZF_Plugin_easygrep_Replace(<q-args>)
            nnoremap <leader>vgr :ZFReplace //<left>
            nmap <leader>vgo <plug>EgMapGrepOptions

            function! ZF_Plugin_easygrep_pcregrep_install()
                call ZF_ModulePackAdd(ZF_ModuleGetApt(), 'pcregrep pcre')
            endfunction
            call ZF_ModuleInstaller('ZF_Plugin_easygrep_pcregrep', 'call ZF_Plugin_easygrep_pcregrep_install()')
            function! ZF_Plugin_easygrep_pcregrep(expr)
                try
                    if match(ZF_system('pcregrep --version'), '[0-9]\+\.[0-9]\+') < 0
                        redraw | echo 'pcregrep not installed'
                        return
                    endif
                endtry

                let expr = a:expr
                let expr = substitute(expr, '"', '\\"', 'g')

                let cmd = 'pcregrep --buffer-size=16M -M -r -s -n'
                if match(expr, '\C[A-Z]') < 0
                    let cmd .= ' -i'
                endif

                let excludeFile = tempname()
                let exclude = ZFIgnoreGet()
                let excludeList = []
                for item in exclude['file']
                    let pattern = ZFIgnorePatternToRegexp(item)
                    if pattern != ''
                        call add(excludeList, pattern)
                    endif
                endfor
                if !empty(excludeList)
                    call writefile(excludeList, excludeFile)
                    let cmd .= ' --exclude-from="' . substitute(excludeFile, '\\', '/', 'g') . '"'
                endif
                for item in exclude['dir']
                    let pattern = ZFIgnorePatternToRegexp(item)
                    if pattern != ''
                        let cmd .= ' --exclude-dir="' . pattern . '"'
                    endif
                endfor

                let cmd .= ' "' . expr . '" *'
                let result = ZF_system(cmd)
                call delete(excludeFile)
                let qflist = []
                let vim_pattern = E2v(a:expr)
                for line in split(result, '\n')
                    let file_line = substitute(line, '^[^:]\+:\([0-9]\+\):.*$', '\1', '') " ^[^:]+:([0-9]+):.*$
                    if file_line == line
                        continue
                    endif
                    let file = substitute(line, '^\([^:]\+\):.*$', '\1', '') " ^([^:]+):.*$
                    let text = substitute(line, '^[^:]\+:[0-9]\+:\(.*\)$', '\1', '') " ^[^:]+:[0-9]+:(.*)$
                    let qflist += [{
                                \ 'filename' : file,
                                \ 'lnum' : file_line,
                                \ 'text' : text,
                                \ 'pattern' : vim_pattern,
                                \ }]
                endfor
                call setqflist(qflist)
                if len(qflist) > 0
                    execute ':silent! M/' . a:expr
                    copen
                else
                    redraw | echo 'no matches for: ' . a:expr
                endif
            endfunction
            command! -nargs=+ ZFGrepExt :call ZF_Plugin_easygrep_pcregrep(<q-args>)
            nnoremap <leader>vge :ZFGrepExt<space>

            function! ZF_Plugin_easygrep_incsearch(cmdline)
                let cmd = substitute(a:cmdline, ' .*', '', '')
                if cmd == 'ZFGrep' || cmd == 'ZFGrepExt'
                    return {
                                \   'delim' : '/',
                                \   'modifiers' : '',
                                \   'pattern' : substitute(a:cmdline, '^ *[^ ]\+ \+', '', ''),
                                \ }
                elseif cmd == 'ZFReplace'
                    let slashToken = nr2char(127)
                    let cmdline = substitute(a:cmdline, '^ *[^ ]\+ \+', '', '')
                    let cmdline = substitute(cmdline, '\\/', slashToken, 'g')
                    let items = split(cmdline, '/')
                    if empty(items)
                        return {}
                    endif
                    return {
                                \   'delim' : '/',
                                \   'modifiers' : '',
                                \   'pattern' : substitute(items[0], slashToken, '\\/', 'g'),
                                \ }
                else
                    return {}
                endif
            endfunction
            let g:eregex_incsearch_custom_cmdparser = {
                        \   'ZFGrep' : function('ZF_Plugin_easygrep_incsearch'),
                        \ }
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_easymotion')
            let g:ZF_Plugin_easymotion = 1
        endif
        if g:ZF_Plugin_easymotion
            ZFPlug 'easymotion/vim-easymotion'
            let g:EasyMotion_do_mapping = 0
            let g:EasyMotion_smartcase = 1
            let g:EasyMotion_use_upper = 1
            let g:EasyMotion_keys = 'ASDGHKLQWERTYUIOPZXCVBNMFJ'
            function! ZF_Plugin_easymotion_colorscheme()
                if get(g:, 'ZF_colorscheme_override', 1) && get(g:, 'ZF_colorscheme_override_easymotion', 1)
                    highlight link EasyMotionTarget Cursor
                    highlight link EasyMotionShade NonText
                    highlight link EasyMotionTarget2First EasyMotionTarget
                    highlight link EasyMotionTarget2Second EasyMotionTarget2First
                    highlight link EasyMotionMoveHL EasyMotionShade
                    highlight link EasyMotionIncSearch EasyMotionShade
                endif
            endfunction
            augroup ZF_Plugin_easymotion_augroup
                autocmd!
                autocmd User ZFVimrcPostNormal
                            \  nmap f <plug>(easymotion-bd-fl)
                            \| xmap f <plug>(easymotion-bd-fl)
                            \| nmap F <plug>(easymotion-Fl)
                            \| xmap F <plug>(easymotion-Fl)
                            \| nmap s <plug>(easymotion-s)
                            \| xmap s <plug>(easymotion-s)
                            \| nmap S <plug>(easymotion-sol-bd-jk)
                            \| xmap S <plug>(easymotion-sol-bd-jk)
                autocmd User ZFVimrcColorscheme call ZF_Plugin_easymotion_colorscheme()
            augroup END
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_eregex')
            let g:ZF_Plugin_eregex = 1
        endif
        if g:ZF_Plugin_eregex
            " ZFPlug 'othree/eregex.vim'
            ZFPlug 'ZSaberLv0/eregex.vim'
            let g:eregex_default_enable = 0
            function! ZF_Plugin_eregex_sort(bang, line1, line2, args)
                let cmd = a:line1 . ',' . a:line2 . 'sort' . a:bang . ' '
                " (?<=\/).*?(?=\/|$)
                let pattern = matchstr(a:args, '\%(\/\)\@<=.\{-}\%(\/\|$\)\@=')
                let patternPos = match(a:args, '\%(\/\)\@<=.\{-}\%(\/\|$\)\@=')
                if len(pattern) == 0 || patternPos < 0
                    let cmd .= a:args
                else
                    let cmd .= strpart(a:args, 0, patternPos)
                    let cmd .= E2v(pattern)
                    let cmd .= strpart(a:args, patternPos + len(pattern))
                endif
                execute cmd
            endfunction
            command! -nargs=* -range=% -bang Sort :call ZF_Plugin_eregex_sort('<bang>', <line1>, <line2>, <q-args>)
            augroup ZF_Plugin_eregex_augroup
                autocmd!
                autocmd User ZFVimrcPostNormal
                            \  nnoremap / :M/
                            \| nnoremap ? /\v
                            \| nnoremap <leader>vr :.,$S//gec<left><left><left><left>
                            \| xnoremap <leader>vr "ty:.,$S/<c-r>t//gec<left><left><left><left>
                            \| nnoremap <leader>zr :.,$S/\<<c-r><c-w>\>//gec<left><left><left><left>
                            \| xnoremap <leader>zr "ty:.,$S/\<<c-r>t\>//gec<left><left><left><left>
                            \| nnoremap <leader>v/ :%S///gn<left><left><left><left>
                            \| xnoremap <leader>v/ "ty:%S/<c-r>t//gn<left><left><left><left>
                            \| nnoremap <leader>z/ :%S/\<<c-r><c-w>\>//gn<left><left><left><left>
                            \| xnoremap <leader>z/ "ty:%S/\<<c-r>t\>//gn<left><left><left><left>
                autocmd User ZFVimLargeFile let b:eregex_incsearch=!b:zf_vim_largefile
            augroup END
            " sed -E 's/from/to/g' file > file
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_expand_region')
            let g:ZF_Plugin_expand_region = 1
        endif
        if g:ZF_Plugin_expand_region
            ZFPlug 'terryma/vim-expand-region'
            if 0 " https://github.com/vim/vim/issues/4024
                nmap t <Plug>(expand_region_expand)
                xmap t <Plug>(expand_region_expand)
                xmap T <Plug>(expand_region_shrink)
            else
                nmap <leader>ER?t <Plug>(expand_region_expand)
                xmap <leader>ER?t <Plug>(expand_region_expand)
                xmap <leader>ER?T <Plug>(expand_region_shrink)
                function! ZF_Plugin_expand_region(mode, direction)
                    if &selection != 'exclusive'
                        call expand_region#next(a:mode, a:direction)
                        return
                    endif
                    if a:mode == 'v'
                        normal! `>hm>
                    endif
                    let selectionSaved = &selection
                    set selection=inclusive
                    call expand_region#next(a:mode, a:direction)
                    normal! l
                    let &selection = selectionSaved
                endfunction
                nnoremap <silent> t :<c-u>call ZF_Plugin_expand_region('n', '+')<cr>
                xnoremap <silent> t :<c-u>call ZF_Plugin_expand_region('v', '+')<cr>
                xnoremap <silent> T :<c-u>call ZF_Plugin_expand_region('v', '-')<cr>
            endif
            let g:expand_region_text_objects = {
                        \   "i'":0, 'i"':0, 'i`':0, 'i)':1, 'i]':1, 'i}':1, 'i>':1,
                        \   "2i'":0, '2i"':0, '2i`':0, 'a)':1, 'a]':1, 'a}':1, 'a>':1,
                        \ }
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_fontsize')
            let g:ZF_Plugin_fontsize = 1
        endif
        if g:ZF_Plugin_fontsize
            ZFPlug 'drmikehenry/vim-fontsize'
            let g:fontsize#timeout = 1
            let g:fontsize#timeoutlen = 1
            nmap + <plug>FontsizeInc
            nmap - <plug>FontsizeDec
            nmap _ <plug>FontsizeDefault
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_helpful')
            let g:ZF_Plugin_helpful = 1
        endif
        if g:ZF_Plugin_helpful
            ZFPlug 'tweekmonster/helpful.vim'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_incsearch')
            let g:ZF_Plugin_incsearch = 1
        endif
        if g:ZF_Plugin_incsearch
            ZFPlug 'haya14busa/incsearch.vim'
            ZFPlug 'haya14busa/incsearch-fuzzy.vim'
            function! ZF_Plugin_incsearch_setting()
                if !exists('g:loaded_incsearch_fuzzy')
                    return
                endif

                if !g:zf_fakevim
                    nmap <silent> ? <Plug>(incsearch-fuzzyword-stay)
                else
                    nnoremap ? /
                endif
            endfunction
            augroup ZF_Plugin_incsearch_augroup
                autocmd!
                autocmd User ZFVimrcPostHigh call ZF_Plugin_incsearch_setting()
            augroup END
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_inline_edit')
            let g:ZF_Plugin_inline_edit = 1
        endif
        if g:ZF_Plugin_inline_edit
            ZFPlug 'AndrewRadev/inline_edit.vim'
            let g:inline_edit_proxy_type = "tempfile"
            let g:inline_edit_modify_statusline = 0
            function! ZF_Plugin_inline_edit_entry(count, filetype) range
                let winnrOld = winnr('$')
                execute "'<,'>InlineEdit " . a:filetype
                if winnrOld == winnr('$')
                    return
                endif
                let undolevelsOld = &undolevels
                set undolevels=-1
                silent! execute "normal! a \<bs>\<esc>gg0"
                let &undolevels = undolevelsOld
                set nomodified
                nnoremap <buffer><expr> q &modified?':w<cr>:bd<cr>':':bd<cr>'
            endfunction
            command! -range=0 -nargs=* -complete=filetype E
                        \ call ZF_Plugin_inline_edit_entry(<count>, <q-args>)
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_json_ponyfill')
            let g:ZF_Plugin_json_ponyfill = !exists('*json_encode')
        endif
        if g:ZF_Plugin_json_ponyfill
            ZFPlug 'retorillo/json-ponyfill.vim'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_LeaderF')
            let g:ZF_Plugin_LeaderF = 1
        endif
        if g:ZF_Plugin_LeaderF
            if v:version < 704 || (v:version == 704 && has("patch1126") == 0)
                let g:ZF_Plugin_LeaderF = 0
            elseif has('python')
                if pyeval("sys.version_info < (2, 7)")
                    let g:ZF_Plugin_LeaderF = 0
                endif
            elseif has('python3')
                if py3eval("sys.version_info < (3, 1)")
                    let g:ZF_Plugin_LeaderF = 0
                endif
            else
                let g:ZF_Plugin_LeaderF = 0
            endif
        endif
        if g:ZF_Plugin_LeaderF
            ZFPlug 'Yggdroot/LeaderF'
            let g:Lf_DefaultExternalTool = ''
            let g:Lf_ShortcutF = '<c-o>'
            let g:Lf_ShortcutB = ''
            let g:Lf_CacheDirectory = g:zf_vim_cache_path.'/leaderf'
            let g:Lf_DefaultMode = 'NameOnly'
            function! ZF_Plugin_LeaderF_updateIgnore()
                let ignore = ZFIgnoreGet()
                let g:Lf_WildIgnore = {'file' : ignore['file'], 'dir' : ignore['dir']}
            endfunction
            augroup ZF_Plugin_LeaderF_augroup
                autocmd!
                autocmd User ZFIgnoreOnUpdate call ZF_Plugin_LeaderF_updateIgnore()
            augroup END
            let g:Lf_MruMaxFiles = 10
            let g:Lf_StlSeparator = {'left' : '', 'right' : ''}
            let g:Lf_UseVersionControlTool = 0
            let g:Lf_CommandMap = {
                        \     '<c-c>' : ['<c-o>','<esc>'],
                        \     '<c-v>' : ['<c-g>'],
                        \     '<c-s>' : ['<c-a>'],
                        \     '<left>' : ['<c-h>'],
                        \     '<right>' : ['<c-l>'],
                        \     '<up>' : ['<c-p>'],
                        \     '<down>' : ['<c-n>'],
                        \ }
            let g:Lf_PreviewResult = {
                        \     'File' : 0,
                        \     'Buffer' : 0,
                        \     'Mru' : 0,
                        \     'Tag' : 0,
                        \     'BufTag' : 0,
                        \     'Function' : 0,
                        \     'Line' : 0,
                        \     'Colorscheme' : 0,
                        \     'Rg' : 0,
                        \     'Gtags' : 0,
                        \ }
            nnoremap <silent> <leader>vo :LeaderfFile<cr>
            nnoremap <silent> <leader>zo :LeaderfFile<cr><f5>
        endif
        if !exists('g:ZF_Plugin_ctrlp')
            let g:ZF_Plugin_ctrlp = 1
        endif
        if g:ZF_Plugin_LeaderF
            let g:ZF_Plugin_ctrlp = 0
        endif
        if g:ZF_Plugin_ctrlp
            ZFPlug 'ctrlpvim/ctrlp.vim'
            let g:ctrlp_by_filename = 1
            let g:ctrlp_regexp = 1
            let g:ctrlp_working_path_mode = ''
            let g:ctrlp_root_markers = []
            let g:ctrlp_use_caching = 1
            let g:ctrlp_clear_cache_on_exit = 0
            let g:ctrlp_cache_dir = g:zf_vim_cache_path.'/ctrlp'
            let g:ctrlp_show_hidden = 1
            let g:ctrlp_prompt_mappings = {
                        \ 'MarkToOpen()':['<c-a>'],
                        \ 'PrtInsert("c")':['<MiddleMouse>','<insert>','<c-g>'],
                        \ 'OpenMulti()':['<c-y>'],
                        \ 'PrtExit()':['<esc>','<c-c>','<c-o>'],
                        \ }
            let g:ctrlp_abbrev = {
                        \ 'gmode': 'i',
                        \ 'abbrevs': []
                        \ }
            function! ZF_Plugin_ctrlp_keymap(c, n)
                for i in range(a:n)
                    let k = nr2char(char2nr(a:c) + i)
                    let g:ctrlp_abbrev['abbrevs'] += [{'pattern': k, 'expanded': k . '.*'}]
                endfor
            endfunction
            call ZF_Plugin_ctrlp_keymap('0', 10)
            call ZF_Plugin_ctrlp_keymap('a', 26)
            call ZF_Plugin_ctrlp_keymap('A', 26)
            call ZF_Plugin_ctrlp_keymap('-', 1)
            call ZF_Plugin_ctrlp_keymap('_', 1)
            let g:ctrlp_map = '<c-o>'
            nnoremap <silent> <leader>vo :CtrlP<cr>
            nnoremap <silent> <leader>zo :CtrlPClearAllCaches<cr>:CtrlP<cr>

            if !exists('g:ZF_Plugin_ctrlp_py_matcher')
                let g:ZF_Plugin_ctrlp_py_matcher = 1
            endif
            if !exists(':pyfile') && !exists(':py3file')
                let g:ZF_Plugin_ctrlp_py_matcher = 0
            endif
            if g:ZF_Plugin_ctrlp_py_matcher
                ZFPlug 'FelikZ/ctrlp-py-matcher'
            endif
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_linediff')
            let g:ZF_Plugin_linediff = 1
        endif
        if g:ZF_Plugin_linediff
            ZFPlug 'AndrewRadev/linediff.vim'
            let g:linediff_first_buffer_command = 'tabnew'
            let g:linediff_second_buffer_command = 'vertical new'

            function! ZF_Plugin_linediff_Diff(line1, line2)
                let splitright_old = &splitright
                set splitright
                call linediff#Linediff(a:line1, a:line2, {})
                let &splitright = splitright_old
                if &diff == 1
                    nnoremap <silent><buffer> q :call ZF_Plugin_linediff_DiffExit()<cr>
                    execute "normal! \<c-w>l"
                    nnoremap <silent><buffer> q :call ZF_Plugin_linediff_DiffExit()<cr>
                endif
            endfunction
            command! -range LinediffBeginWrap call ZF_Plugin_linediff_Diff(<line1>, <line2>)
            xnoremap ZD :LinediffBeginWrap<cr>

            function! ZF_Plugin_linediff_DiffExit()
                while 1
                    if &diff != 1
                        break
                    endif

                    execute "normal! \<c-w>h"
                    let modified = &modified
                    execute "normal! \<c-w>l"
                    let modified = (modified||&modified)
                    if modified != 1
                        break
                    endif

                    echo 'diff updated, save?'
                    echo '  (y)es'
                    echo '  (n)o'
                    echo 'choose: '
                    let cmd = getchar()
                    if cmd != char2nr('y')
                        break
                    endif

                    execute "normal! \<c-w>h"
                    update
                    execute "normal! \<c-w>l"
                    update
                    bd
                    redraw!
                    echo 'diff updated'
                    return
                endwhile

                execute 'LinediffReset!'
                redraw!
                echo 'diff canceled'
            endfunction
            nnoremap ZD :call ZF_Plugin_linediff_DiffExit()<cr>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_matchup')
            let g:ZF_Plugin_matchup = 1
        endif
        if !exists('*matchaddpos') || v:version <= 704
            let g:ZF_Plugin_matchup = 0
        endif
        if g:ZF_Plugin_matchup
            ZFPlug 'andymass/vim-matchup'
            let g:matchup_mappings_enabled = 0
            let g:matchup_mouse_enabled = 0
            let g:matchup_text_obj_enabled = 0
            let g:matchup_matchparen_timeout = 50
            let g:matchup_matchparen_insert_timeout = 50
            let g:matchup_matchparen_offscreen = {}
            let g:matchup_matchparen_deferred = 1
            let g:matchup_matchparen_deferred_show_delay = 200
            let g:matchup_matchparen_pumvisible = 0
            let g:matchup_matchparen_nomode = "ivV\<c-v>"
            if !g:zf_fakevim
                nmap % <plug>(matchup-%)
                xmap % <plug>(matchup-%)
            else
                noremap % %
            endif
            augroup ZF_Plugin_matchup_augroup
                autocmd!
                function! s:ZF_Plugin_matchup_low_perf()
                    if g:zf_low_performance
                        let g:matchup_matchparen_stopline = 20
                    else
                        let g:matchup_matchparen_stopline = 300
                    endif
                endfunction
                autocmd User ZFVimLowPerf,ZFVimrcPostLow call s:ZF_Plugin_matchup_low_perf()
            augroup END
        endif
        if !exists('g:ZF_Plugin_matchit')
            let g:ZF_Plugin_matchit = 1
        endif
        if v:version < 704 || g:ZF_Plugin_matchup
            let g:ZF_Plugin_matchit = 0
        endif
        if g:ZF_Plugin_matchit
            ZFPlug 'adelarsq/vim-matchit'
        endif

        " ==================================================
        " some memo about scp to here and there:
        "     ls | ssh user@remotehost 'cat > /xxx/remotefile'
        "     ssh user@remotehost 'cat > /xxx/remotefile' | grep xxx
        if !exists('g:ZF_Plugin_nerdtree')
            let g:ZF_Plugin_nerdtree = 1
        endif
        if g:ZF_Plugin_nerdtree
            ZFPlug 'scrooloose/nerdtree'
            let g:NERDTreeNodeDelimiter = "\t"
            let g:NERDTreeSortHiddenFirst = 1
            let g:NERDTreeQuitOnOpen = 1
            let g:NERDTreeShowHidden = 1
            let g:NERDTreeShowLineNumbers = 1
            let g:NERDTreeWinSize = 50
            let g:NERDTreeMinimalUI = 1
            let g:NERDTreeDirArrows = 0
            let g:NERDTreeAutoDeleteBuffer = 1
            let g:NERDTreeHijackNetrw = 1
            let g:NERDTreeIgnore=[]
            let g:NERDTreeBookmarksFile = g:zf_vim_cache_path.'/NERDTreeBookmarks'
            let g:NERDTreeCascadeSingleChildDir = 0
            let g:NERDTreeDirArrowExpandable = '+'
            let g:NERDTreeDirArrowCollapsible = '~'
            nnoremap <silent> <leader>ve :NERDTreeToggle<cr>
            nnoremap <silent> <leader>ze :NERDTreeFind<cr>
            augroup ZF_Plugin_nerdtree_augroup
                autocmd!
                autocmd FileType nerdtree
                            \  setlocal tabstop=2
                            \| nmap <buffer><silent> <leader>ze :NERDTreeToggle<cr>:NERDTreeFind<cr>
                            \| nmap <buffer><silent> cd \NERDTree?cd\NERDTree?CD:pwd<cr>
                            \| nmap <buffer><silent> X gg\NERDTree?X
                            \| nmap <buffer><silent> u \NERDTree?u:let _l=line('.')<cr>gg\NERDTree?cd\NERDTree?CD:<c-r>=_l<cr><cr>:pwd<cr>
                            \| nnoremap <buffer><silent> cf :call ZF_Plugin_nerdtree_excludeToggle()<cr>
                autocmd User ZFIgnoreOnUpdate call ZF_Plugin_nerdtree_excludeUpdate()
            augroup END
            function! ZF_Plugin_nerdtree_excludeUpdate()
                if exists('b:ZF_Plugin_nerdtree_excludeToggleFlag')
                    let g:NERDTreeIgnore = ZF_Plugin_nerdtree_excludeList()
                    NERDTreeRefreshRoot
                endif
            endfunction
            function! ZF_Plugin_nerdtree_excludeToggle()
                if !exists('b:ZF_Plugin_nerdtree_excludeToggleFlag')
                    let b:ZF_Plugin_nerdtree_excludeToggleFlag = 1
                    let g:ZF_Plugin_nerdtree_statuslineSaved = g:NERDTreeStatusline
                    let g:NERDTreeIgnore = ZF_Plugin_nerdtree_excludeList()
                    NERDTreeRefreshRoot
                else
                    normal \NERDTree?cf
                    let b:ZF_Plugin_nerdtree_excludeToggleFlag = 1 - b:ZF_Plugin_nerdtree_excludeToggleFlag
                endif
                if b:ZF_Plugin_nerdtree_excludeToggleFlag
                    let g:NERDTreeStatusline = 'NOTE: filter on'
                else
                    let g:NERDTreeStatusline = g:ZF_Plugin_nerdtree_statuslineSaved
                endif
                let &l:statusline = g:NERDTreeStatusline
            endfunction
            function! ZF_Plugin_nerdtree_excludeList()
                return ZFIgnoreToRegexp(ZFIgnoreGet({
                            \   'bin' : 0,
                            \   'media' : 0,
                            \ }))
            endfunction
            let g:NERDTreeMapActivateNode = 'o'
            let g:NERDTreeMapChangeRoot = '\NERDTree?CD'
            let g:NERDTreeMapChdir = '\NERDTree?cd'
            let g:NERDTreeMapCloseChildren = '\NERDTree?X'
            let g:NERDTreeMapCloseDir = 'x'
            let g:NERDTreeMapDeleteBookmark = ''
            let g:NERDTreeMapMenu = 'm'
            let g:NERDTreeMapHelp = ''
            let g:NERDTreeMapJumpFirstChild = ''
            let g:NERDTreeMapJumpLastChild = ''
            let g:NERDTreeMapJumpNextSibling = ''
            let g:NERDTreeMapJumpParent = ''
            let g:NERDTreeMapJumpPrevSibling = ''
            let g:NERDTreeMapJumpRoot = ''
            let g:NERDTreeMapOpenExpl = ''
            let g:NERDTreeMapOpenInTab = ''
            let g:NERDTreeMapOpenInTabSilent = ''
            let g:NERDTreeMapOpenRecursively = 'O'
            let g:NERDTreeMapOpenSplit = ''
            let g:NERDTreeMapOpenVSplit = ''
            let g:NERDTreeMapPreview = ''
            let g:NERDTreeMapPreviewSplit = ''
            let g:NERDTreeMapPreviewVSplit = ''
            let g:NERDTreeMapQuit = 'q'
            let g:NERDTreeMapRefresh = ''
            let g:NERDTreeMapRefreshRoot = 'r'
            let g:NERDTreeMapToggleBookmarks = ''
            let g:NERDTreeMapToggleFiles = ''
            let g:NERDTreeMapToggleFilters = '\NERDTree?cf'
            let g:NERDTreeMapToggleHidden = 'ch'
            let g:NERDTreeMapToggleZoom = ''
            let g:NERDTreeMapUpdir = '\NERDTree?u'
            let g:NERDTreeMapUpdirKeepOpen = ''
            let g:NERDTreeMapCWD = 'CD'

            if get(g:, 'ZF_Plugin_nerdtree_fs_menu', 1)
                ZFPlug 'ZSaberLv0/nerdtree_fs_menu'
                let g:loaded_nerdtree_exec_menuitem = 1
                let g:loaded_nerdtree_fs_menu = 1
            endif

            if get(g:, 'ZF_Plugin_nerdtree_menu_util', 1)
                ZFPlug 'ZSaberLv0/nerdtree_menu_util'
            endif
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_searchindex')
            let g:ZF_Plugin_searchindex = 1
        endif
        if g:ZF_Plugin_searchindex
            " ZFPlug 'google/vim-searchindex'
            ZFPlug 'ZSaberLv0/vim-searchindex'
            let g:searchindex_improved_star = 0
            augroup ZF_Plugin_searchindex_augroup
                autocmd!
                function! s:ZF_Plugin_searchindex_low_perf()
                    if g:zf_low_performance
                        let g:searchindex_line_limit = 1000
                    else
                        let g:searchindex_line_limit = 1000000
                    endif
                endfunction
                autocmd User ZFVimLowPerf,ZFVimrcPostLow call s:ZF_Plugin_searchindex_low_perf()
            augroup END
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ShowTrailingWhitespace')
            let g:ZF_Plugin_ShowTrailingWhitespace = 1
        endif
        if g:ZF_Plugin_ShowTrailingWhitespace
            ZFPlug 'vim-scripts/ShowTrailingWhitespace'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_signature')
            let g:ZF_Plugin_signature = 1
        endif
        if g:ZF_Plugin_signature
            ZFPlug 'kshenoy/vim-signature'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_supertab')
            let g:ZF_Plugin_supertab = 0
        endif
        if g:ZF_Plugin_supertab
            ZFPlug 'ervandew/supertab'
            let g:SuperTabDefaultCompletionType = 'context'
            let g:SuperTabContextDefaultCompletionType = '<c-p>'
            let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
            let g:SuperTabContextTextOmniPrecedence = ['&completefunc', '&omnifunc']
            let g:SuperTabContextDiscoverDiscovery = ['&omnifunc:<c-x><c-o>', '&completefunc:<c-x><c-u>']
            let g:SuperTabLongestEnhanced = 1
            let g:SuperTabLongestHighlight = 1
            function! ZF_Plugin_supertab_chain()
                if &omnifunc != '' && exists('*SuperTabChain') && exists('*SuperTabSetDefaultCompletionType')
                    call SuperTabChain(&omnifunc, '<c-p>')
                    call SuperTabSetDefaultCompletionType('<c-x><c-u>')
                endif
            endfunction
            augroup ZF_Plugin_supertab_augroup
                autocmd!
                if get(g:, 'ZF_Plugin_supertab_autoChain', 1)
                    autocmd FileType * call ZF_Plugin_supertab_chain()
                endif
            augroup END
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_surround')
            let g:ZF_Plugin_surround = 1
        endif
        if g:ZF_Plugin_surround
            ZFPlug 'tpope/vim-surround'
            let g:surround_no_mappings = 1
            let g:surround_no_insert_mappings = 1
            augroup ZF_Plugin_surround_augroup
                autocmd!
                autocmd User ZFVimrcPostNormal
                            \  nmap rd <plug>Dsurround
                            \| nmap RD <plug>Dsurround
                            \| nmap rc <plug>Csurround
                            \| nmap RC <plug>CSurround
                            \| xmap r <plug>VSurround
                            \| xmap R <plug>VgSurround
            augroup END
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ultisnips')
            let g:ZF_Plugin_ultisnips = 1
        endif
        if v:version < 704
                    \ || (!has('python') && !has('python3'))
                    \ || (has('win32unix') && !has('python3'))
            let g:ZF_Plugin_ultisnips = 0
        endif
        if g:ZF_Plugin_ultisnips
            if has('python3')
                ZFPlug 'SirVer/ultisnips'
            else
                ZFPlug 'ZSaberLv0/ultisnips_py2'
            endif
            let g:UltiSnipsListSnippets = "<c-o>"
            let g:UltiSnipsExpandTrigger = "<c-u>"
            let g:UltiSnipsJumpForwardTrigger = "<c-o>"
            let g:UltiSnipsJumpBackwardTrigger = "<c-u>"
            let g:UltiSnipsRemoveSelectModeMappings = 0
        endif

        if !exists('g:ZF_Plugin_snipmate')
            let g:ZF_Plugin_snipmate = (g:ZF_Plugin_ultisnips ? 0 : 1)
        endif
        if g:ZF_Plugin_snipmate
            " https://github.com/garbas/vim-snipmate/issues/285
            if &selection != 'exclusive'
                ZFPlug 'MarcWeber/vim-addon-mw-utils'
                ZFPlug 'tomtom/tlib_vim'
                ZFPlug 'garbas/vim-snipmate'
                imap <c-o> <Plug>snipMateNextOrTrigger
                smap <c-o> <Plug>snipMateNextOrTrigger
                imap <c-u> <Plug>snipMateBack
                smap <c-u> <Plug>snipMateBack
                let g:snipMate = {
                            \   'snippet_version' : 1,
                            \   'override' : 1,
                            \   'always_choose_first' : 1,
                            \   'no_match_completion_feedkeys_chars' : '',
                            \ }
            else
                ZFPlug 'Shougo/neosnippet.vim'
                let g:neosnippet#enable_snipmate_compatibility = 1
                let g:neosnippet#data_directory = g:zf_vim_cache_path . '/neosnippet'
                let g:neosnippet#enable_conceal_markers = 0
                imap <c-o> <Plug>(neosnippet_expand_or_jump)
                smap <c-o> <Plug>(neosnippet_expand_or_jump)
                xmap <c-o> <Plug>(neosnippet_expand_target)
            endif
        endif

        if !exists('g:ZF_Plugin_ZF_ultisnips')
            let g:ZF_Plugin_ZF_ultisnips = ((g:ZF_Plugin_ultisnips || g:ZF_Plugin_snipmate) ? 1 : 0)
        endif
        if g:ZF_Plugin_ZF_ultisnips
            ZFPlug 'ZSaberLv0/ZF_ultisnips'
            function! ZF_Plugin_ZFSnipEdit(...)
                let ft = get(a:, 1, &filetype)
                if empty(ft)
                    let ft = 'all'
                endif
                let path = g:zf_vim_plugin_path . '/ZF_ultisnips/snippets/' . ft . '.snippets'
                execute 'edit ' . substitute(path, ' ', '\\ ', 'g')
            endfunction
            command! -nargs=? -complete=filetype ZFSnipEdit :call ZF_Plugin_ZFSnipEdit(<f-args>)

            if g:ZF_Plugin_ultisnips
                let g:UltiSnipsListSnippets = ''
                inoremap <silent> <c-o> <C-R>=ZF_ultisnips_ListSnippets_onekey()<cr>
                snoremap <silent> <c-o> <Esc>:call ZF_ultisnips_ListSnippets_onekey()<cr>
            endif
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_vZoom')
            let g:ZF_Plugin_vZoom = 1
        endif
        if g:ZF_Plugin_vZoom
            ZFPlug 'KabbAmine/vZoom.vim'
            nmap WM <Plug>(vzoom)
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimBackup')
            let g:ZF_Plugin_ZFVimBackup = 1
        endif
        if g:ZF_Plugin_ZFVimBackup
            ZFPlug 'ZSaberLv0/ZFVimBackup'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimCmdMenu')
            let g:ZF_Plugin_ZFVimCmdMenu = 1
        endif
        if g:ZF_Plugin_ZFVimCmdMenu
            ZFPlug 'ZSaberLv0/ZFVimCmdMenu'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimDirDiff')
            let g:ZF_Plugin_ZFVimDirDiff = 1
        endif
        if g:ZF_Plugin_ZFVimDirDiff
            ZFPlug 'ZSaberLv0/ZFVimDirDiff'
            nnoremap <leader>vdd :ZFDirDiff<space>
            nnoremap <silent> <leader>vdm :ZFDirDiffMark<cr>

            function! ZF_DiffGit(repo)
                redraw!
                echo 'updating ' . a:repo . ' ...'
                let tmp_path = g:zf_vim_cache_path . '/_zf_diffgit_tmp_'
                call ZF_rm(tmp_path)
                call ZF_system('git clone ' . a:repo . ' "' . tmp_path . '"')
                execute ':ZFDirDiff ' . tmp_path . ' .'
                augroup ZF_DiffGit_autoClean_augroup
                    autocmd!
                    autocmd VimLeavePre * call ZF_rm(g:zf_vim_cache_path . '/_zf_diffgit_tmp_')
                augroup END
            endfunction
            command! -nargs=+ ZFDiffGit :call ZF_DiffGit(<q-args>)
            function! ZF_DiffGitGetParam()
                for line in split(ZF_system('git remote -v'), "\n")
                    " ^origin[ \t]+(.*?)[ \t]+\((fetch|push)\)$
                    let repo = substitute(line, '^origin[ \t]\+\(.\{-}\)[ \t]\+(\(fetch\|push\))$', '\1', '')
                    if repo != line
                        return repo
                    endif
                endfor
                return g:zf_githost . '/' . g:zf_git_user_name . '/' . fnamemodify(getcwd(), ':t')
            endfunction
            nnoremap <leader>vdg :ZFDiffGit <c-r>=ZF_DiffGitGetParam()<cr>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimEscape')
            let g:ZF_Plugin_ZFVimEscape = 1
        endif
        if g:ZF_Plugin_ZFVimEscape
            ZFPlug 'ZSaberLv0/ZFVimEscape'
            ZFPlug 'retorillo/md5.vim'
            xnoremap <leader>ce <esc>:call ZF_VimEscape('v')<cr>
            nnoremap <leader>ce :call ZF_VimEscape()<cr>

            function! ZF_Plugin_ZFVimEscape_install()
                call ZF_ModulePackAdd(ZF_ModuleGetPip(), 'pyqrcode')
            endfunction
            call ZF_ModuleInstaller('ZFVimEscape', 'call ZF_Plugin_ZFVimEscape_install()')
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimExpand')
            let g:ZF_Plugin_ZFVimExpand = 1
        endif
        if g:ZF_Plugin_ZFVimExpand
            ZFPlug 'ZSaberLv0/ZFVimExpand'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimFoldBlock')
            let g:ZF_Plugin_ZFVimFoldBlock = 1
        endif
        if g:ZF_Plugin_ZFVimFoldBlock
            ZFPlug 'ZSaberLv0/ZFVimFoldBlock'
            nnoremap ZB q::call ZF_FoldBlockTemplate()<cr>
            nnoremap ZF :ZFFoldBlock //<left>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimFormater')
            let g:ZF_Plugin_ZFVimFormater = 1
        endif
        if g:ZF_Plugin_ZFVimFormater
            ZFPlug 'ZSaberLv0/ZFVimFormater'
            ZFPlug 'ZSaberLv0/ZFVimBeautifier'
            ZFPlug 'ZSaberLv0/ZFVimBeautifierTemplate'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimGitUtil')
            let g:ZF_Plugin_ZFVimGitUtil = 1
        endif
        if g:ZF_Plugin_ZFVimGitUtil
            ZFPlug 'ZSaberLv0/ZFVimGitUtil'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimHexEditor')
            let g:ZF_Plugin_ZFVimHexEditor = 1
        endif
        if g:ZF_Plugin_ZFVimHexEditor
            ZFPlug 'ZSaberLv0/ZFVimHexEditor'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimIgnore')
            let g:ZF_Plugin_ZFVimIgnore = 1
        endif
        if g:ZF_Plugin_ZFVimIgnore
            ZFPlug 'ZSaberLv0/ZFVimIgnore'
            nnoremap <leader>vgi :ZFIgnoreToggle<cr>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimAsciiPlayer')
            let g:ZF_Plugin_ZFVimAsciiPlayer = 1
        endif
        if g:ZF_Plugin_ZFVimAsciiPlayer
            ZFPlug 'ZSaberLv0/ZFVimAsciiPlayer'

            if !exists('g:ZF_Plugin_ZFVimAsciiPlayer_image')
                let g:ZF_Plugin_ZFVimAsciiPlayer_image = 1
            endif
            if g:ZF_Plugin_ZFVimAsciiPlayer_image
                ZFPlug 'ZSaberLv0/ZFVimAsciiPlayer_image'
                function! ZF_Plugin_ZFVimAsciiPlayer_image_install()
                    call ZF_ModulePackAdd(ZF_ModuleGetPip(), 'docopt Pillow')
                endfunction
                call ZF_ModuleInstaller('ZF_Plugin_ZFVimAsciiPlayer_image', 'call ZF_Plugin_ZFVimAsciiPlayer_image_install()')
            endif
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimIM')
            let g:ZF_Plugin_ZFVimIM = 1
        endif
        if g:ZF_Plugin_ZFVimIM
            ZFPlug 'ZSaberLv0/ZFVimIM'
            if get(g:, 'ZF_Plugin_ZFVimIM_pinyin', 1)
                ZFPlug 'ZSaberLv0/ZFVimIM_pinyin'
            endif
            if get(g:, 'ZF_Plugin_ZFVimIM_openapi', 1)
                ZFPlug 'ZSaberLv0/ZFVimIM_openapi'
            endif

            function! ZF_Plugin_ZFVimIM_statusline_setup()
                if exists('*ZFVimIME_IMEStatusline')
                    let &statusline = substitute(&statusline, ' *%k *', '%{ZFVimIME_IMEStatusline()}', 'g')
                endif
                augroup ZF_Plugin_ZFVimIM_statusline_qf_augroup
                    autocmd!
                    autocmd BufWinEnter quickfix,qf call ZF_Plugin_ZFVimIM_statusline_update()
                augroup END
            endfunction
            function! ZF_Plugin_ZFVimIM_statusline_update()
                if exists('*ZFVimIME_IMEStatusline')
                    let &l:statusline = substitute(&l:statusline, ' *%k *', '%{ZFVimIME_IMEStatusline()}', 'g')
                endif
            endfunction
            augroup ZF_Plugin_ZFVimIM_statusline_augroup
                autocmd!
                autocmd User ZFVimrcPostNormal call ZF_Plugin_ZFVimIM_statusline_setup()
            augroup END
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimIndentMove')
            let g:ZF_Plugin_ZFVimIndentMove = 1
        endif
        if g:ZF_Plugin_ZFVimIndentMove
            ZFPlug 'ZSaberLv0/ZFVimIndentMove'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimJob')
            let g:ZF_Plugin_ZFVimJob = 1
        endif
        if g:ZF_Plugin_ZFVimJob
            ZFPlug 'ZSaberLv0/ZFVimJob'
            nnoremap <leader>va :ZFAsyncRun<space>
            nnoremap <leader>za :ZFAsyncRunSend<space>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimPopup')
            let g:ZF_Plugin_ZFVimPopup = 1
        endif
        if g:ZF_Plugin_ZFVimPopup
            ZFPlug 'ZSaberLv0/ZFVimPopup'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimTmpFile')
            let g:ZF_Plugin_ZFVimTmpFile = 1
        endif
        if g:ZF_Plugin_ZFVimTmpFile
            ZFPlug 'ZSaberLv0/ZFVimTmpFile'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimToc')
            let g:ZF_Plugin_ZFVimToc = 1
        endif
        if g:ZF_Plugin_ZFVimToc
            ZFPlug 'ZSaberLv0/ZFVimToc'
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimTxtHighlight')
            let g:ZF_Plugin_ZFVimTxtHighlight = 1
        endif
        if g:ZF_Plugin_ZFVimTxtHighlight
            ZFPlug 'ZSaberLv0/ZFVimTxtHighlight'
            nnoremap <leader>cth :call ZF_VimTxtHighlightToggle()<cr>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimrcUtil')
            let g:ZF_Plugin_ZFVimrcUtil = 1
        endif
        if g:ZF_Plugin_ZFVimrcUtil
            ZFPlug 'ZSaberLv0/ZFVimrcUtil'
            function! ZF_VimrcEditLocal()
                let file = g:zf_vim_data_path . '/ZFVimModule/vimrc.local.vim'
                execute 'edit ' . substitute(file, ' ', '\\ ', 'g')
                if filereadable(file)
                    return
                endif
                call setline(1, [
                            \   "",
                            \   "\" see here for possible complete engines:",
                            \   "\"     https://github.com/ZSaberLv0/zf_vimrc.ext/tree/master/ZFPlugPost/complete_engine",
                            \   "\" let g:ZF_Plugin_complete_engine = 'coc'",
                            \   "",
                            \   "function! s:localConfig()",
                            \   "    \" ZFPlug 'UserName/RepoName'",
                            \   "endfunction",
                            \   "autocmd User ZFVimrcPlug call s:localConfig()",
                            \   "",
                            \   "\" let g:zf_git_user_token = 'pwd_or_token'",
                            \   "\" let g:zf_git = [",
                            \   "\"             \\   {",
                            \   "\"             \\     'repo' : '',",
                            \   "\"             \\     'repo_regexp' : 'github.com',",
                            \   "\"             \\     'git_user_email' : 'YourEmail',",
                            \   "\"             \\     'git_user_name' : 'YourUserName',",
                            \   "\"             \\     'git_user_pwd' : 'YourPwdOrToken',",
                            \   "\"             \\   },",
                            \   "\"             \\ ]",
                            \   "",
                            \   "if !exists('g:ZFIgnoreData')",
                            \   "    let g:ZFIgnoreData = {}",
                            \   "endif",
                            \   "let g:ZFIgnoreData['MyCustomIgnore'] = {",
                            \   "            \\   'common' : {",
                            \   "            \\     'file' : {",
                            \   "            \\     },",
                            \   "            \\     'dir' : {",
                            \   "            \\     },",
                            \   "            \\   },",
                            \   "            \\   'ZFBackup' : {",
                            \   "            \\     'file' : {",
                            \   "            \\       '*.png' : 1,",
                            \   "            \\     },",
                            \   "            \\     'dir' : {",
                            \   "            \\     },",
                            \   "            \\   },",
                            \   "            \\ }",
                            \   "",
                            \   "if !exists('g:ZFAutoScript')",
                            \   "    let g:ZFAutoScript = {}",
                            \   "endif",
                            \   "\" let g:ZFAutoScript['projDir1'] = 'shell_to_run'",
                            \   "\" let g:ZFAutoScript['projDir2'] = {",
                            \   "\"             \\     'jobList' : [",
                            \   "\"             \\       [",
                            \   "\"             \\         {",
                            \   "\"             \\           'jobCmd' : 'shell_to_run',",
                            \   "\"             \\           'jobCwd' : 'projDir',",
                            \   "\"             \\         },",
                            \   "\"             \\       ],",
                            \   "\"             \\       {",
                            \   "\"             \\         'jobCmd' : [",
                            \   "\"             \\           \"call ZFAutoScriptRun('projDir')\",",
                            \   "\"             \\         ],",
                            \   "\"             \\       },",
                            \   "\"             \\     ],",
                            \   "\"             \\   }",
                            \   "",
                            \   "\" let g:ZFAutoFormatFtList = ['yourFileType']",
                            \   "",
                            \ ])
            endfunction
            nnoremap <leader>vimrt :call ZF_VimrcEditLocal()<cr>
            nnoremap <leader>vimro :call ZF_VimrcEditOrg()<cr>
            nnoremap <leader>vimrc :call ZF_VimrcEdit()<cr>
            nnoremap <leader>vimclean :call ZF_VimClean()<cr>
            nnoremap <leader>vimrd :call ZF_VimrcDiff()<cr>
            nnoremap <leader>vimru :call ZF_VimrcUpdate()<cr>
            nnoremap <leader>vimrp :call ZF_VimrcPush()<cr>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimTagSetting')
            let g:ZF_Plugin_ZFVimTagSetting = 1
        endif
        if g:ZF_Plugin_ZFVimTagSetting
            ZFPlug 'ZSaberLv0/ZFVimTagSetting'
            nnoremap <leader>ctagl :call ZF_TagsFileLocal()<cr>
            nnoremap <leader>ctagg :call ZF_TagsFileGlobal()<cr>
            nnoremap <leader>ctaga :call ZF_TagsFileGlobalAdd()<cr>
            nnoremap <leader>ctagr :call ZF_TagsFileRemove()<cr>
            nnoremap <leader>ctagv :execute ':edit ' . ZF_TagsFileGlobalPath()<cr>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimTerminal')
            let g:ZF_Plugin_ZFVimTerminal = 1
        endif
        if g:ZF_Plugin_ZFVimTerminal
            ZFPlug 'ZSaberLv0/ZFVimTerminal'
            nnoremap <leader>zs :ZFTerminal<space>
        endif

        " ==================================================
        if !exists('g:ZF_Plugin_ZFVimUtil')
            let g:ZF_Plugin_ZFVimUtil = 1
        endif
        if g:ZF_Plugin_ZFVimUtil
            ZFPlug 'ZSaberLv0/ZFVimUtil'
            function! ZF_Plugin_ZFVimUtil_install()
                call ZF_ModulePackAdd(ZF_ModuleGetNpm(), 'http-server')
                call ZF_ModulePackAdd(ZF_ModuleGetPip(), 'pillow numpy')
            endfunction
            call ZF_ModuleInstaller('ZFVimUtil', 'call ZF_Plugin_ZFVimUtil_install()')

            nnoremap <leader>vs :ZFExecShell<space>
            nnoremap <leader>vc :ZFExecCmd<space>
            nnoremap <leader>calc :ZFCalc<space>
            nnoremap <leader>vdb :ZFDiffBuffer<space>
            nnoremap <leader>vde :ZFDiffExit<cr>
            nnoremap <leader>vvo :ZFOpenAllFileInClipboard<cr>
            nnoremap <leader>vvO :ZFRunAllFileInClipboard<cr>
            nnoremap <leader>vvs :ZFRunShellScriptInClipboard<cr>
            nnoremap <leader>vvc :ZFRunVimCommandInClipboard<cr>
            nnoremap <leader>vn :ZFNumberConvert<cr>
            nnoremap ZB q::call ZF_FoldBlockTemplate()<cr>
            nnoremap Z) :call ZF_FoldBrace(')')<cr>
            nnoremap Z] :call ZF_FoldBrace(']')<cr>
            nnoremap Z} :call ZF_FoldBrace('}')<cr>
            nnoremap Z> :call ZF_FoldBrace('>')<cr>
            nnoremap <leader>cc :call ZF_Convert()<cr>
            nnoremap <leader>cm :call ZF_Toggle()<cr>
        endif
    endif " common plugins for happy text editing


    " ==================================================
    call s:subModule('ZFPlugPost')
    augroup ZF_VimrcPlug_augroup
        autocmd!
        autocmd User ZFVimrcPlug silent
        doautocmd User ZFVimrcPlug
    augroup END
    call plug#end()
endif


" ==================================================
if 1 && !g:zf_fakevim && !get(g:, 'zf_no_theme', 0) " theme
    augroup ZF_colorscheme_augroup
        autocmd!
        autocmd User ZFVimrcColorscheme silent
        autocmd ColorScheme * doautocmd User ZFVimrcColorscheme
    augroup END

    function! ZFColorscheme()
        if !empty(get(g:, 'zf_color_name_256', '')) && !empty(globpath(&rtp, 'colors/' . g:zf_color_name_256 . '.vim'))
            execute 'set background=' . g:zf_color_bg_256
            execute 'colorscheme ' . g:zf_color_name_256
        elseif !empty(get(g:, 'zf_color_name_default', '')) && !empty(globpath(&rtp, 'colors/' . g:zf_color_name_default . '.vim'))
            execute 'set background=' . g:zf_color_bg_default
            execute 'colorscheme ' . g:zf_color_name_default
        else
            set background=dark
            colorscheme murphy
        endif
        doautocmd User ZFVimrcColorscheme
    endfunction
    call ZFColorscheme()
endif


" ==================================================
if 1 && !g:zf_fakevim " final setup
    augroup ZF_VimrcPost_augroup
        autocmd!
        autocmd User ZFVimrcPostLow silent
        autocmd User ZFVimrcPostNormal silent
        autocmd User ZFVimrcPostHigh silent
        function! s:finalSetup()
            call s:subModule('ZFFinish')
            doautocmd User ZFVimrcPostLow
            doautocmd User ZFVimrcPostNormal
            doautocmd User ZFVimrcPostHigh
            doautocmd User ZFVimLowPerf
            if exists('*s:PlugCheck')
                call s:PlugCheck()
            endif
        endfunction
        if exists('v:vim_did_enter') && v:vim_did_enter
            call s:finalSetup()
        else
            autocmd VimEnter * call s:finalSetup()
        endif
    augroup END
endif

