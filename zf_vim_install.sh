#!bash

# ============================================================
# global check
_git_exist=0
git --version >/dev/null 2>&1 && _git_exist=1 || _git_exist=0
if test "x-$_git_exist" = "x-0"; then
    echo "[ZFVim] error: git not installed"
    exit
fi

_vim_exist=0
vim --version >/dev/null 2>&1 && _vim_exist=1 || _vim_exist=0
_nvim_exist=0
nvim --version >/dev/null 2>&1 && _nvim_exist=1 || _nvim_exist=0
if test "x-$_vim_exist" = "x-1" ; then
    ZF_VIM=vim
elif test "x-$_nvim_exist" = "x-1" ; then
    ZF_VIM=nvim
else
    echo "[ZFVim] error: vim or nvim not installed"
    exit
fi

# ============================================================
# config check
if test "x-$ZFVim_githost" = "x-" ; then
    echo "[ZFVim] available host:"
    echo "    https://github.com               (default)"
    echo "    https://github.com.cnpmjs.org    (recommend for Chinese users)"
    echo "    https://hub.fastgit.org"
    read -p "[ZFVim] enter git host or empty for default: " ZFVim_githost </dev/tty
fi

if test "x-$ZFVim_local" = "x-" ; then
    read -p "[ZFVim] install locally? [n/y/path_to_install]: " ZFVim_local </dev/tty
fi

if test "x-$ZFVim_force" = "x-" ; then
    read -p "[ZFVim] clean before install? [n/y]: " ZFVim_force </dev/tty
fi

if test "x-$ZFVim_modules" = "x-" ; then
    read -p "[ZFVim] install additional command line tools? [n/y]: " ZFVim_modules </dev/tty
fi

echo "========================================"
echo "[ZFVim] install settings"
echo ""
echo "    git host        : ${ZFVim_githost:-https://github.com}"
echo "    locally         : ${ZFVim_local:-n}"
echo "    clean install   : ${ZFVim_force:-n}"
echo "    install modules : ${ZFVim_modules:-n}"
echo ""
read -p "confirm install? [y/n]: " _confirm </dev/tty

if ! test "x-$_confirm" = "x-y" && ! test "x-$_confirm" = "x-" ; then
    exit 0
fi

echo "========================================"
echo "[ZFVim] installing, please wait..."


# ============================================================
# default config
if test "x-$ZFVim_githost" = "x-" ; then
    _zf_githost="https://github.com"
else
    _zf_githost=$ZFVim_githost
fi


# ============================================================
# functions
zf_vim_githost_setup () {
    _githost_file=$1
    mkdir -p ${_githost_file%[/\\]*}
    if ! test "x-$ZFVim_githost" = "x-" ; then
        echo "let g:zf_githost = '$ZFVim_githost'" > "$_githost_file"
    fi
}

zf_vim_install_plugin () {
    _p_vim=$1
    _p_nvim=$2
    $_p_vim "+:let g:ZFVimrcUtil_AutoUpdateOverride = 1" "+silent! PlugClean!" "+silent! PlugUpdate" +qall </dev/tty

    # nvim may have different plugins, update again
    if test "x-$_vim_exist" = "x-1" && test "x-$_nvim_exist" = "x-1" ; then
        $_p_nvim "+silent! PlugInstall" +qall </dev/tty
    fi

    # try to install external tools
    if test "x-$ZFVim_modules" = "x-y" ; then
        $_p_vim +ZFModuleInstall +qall </dev/tty
    fi
}


# ============================================================
# local mode
if ! test "x-$ZFVim_local" = "x-" && ! test "x-$ZFVim_local" = "x-n" ; then
    if test "x-$ZFVim_local" = "x-y" ; then
        localPath="zf_vimrc.local"
    else
        localPath=$ZFVim_local
    fi

    if test -e "$localPath/zf_vimrc.vim" && ! test "x-$ZFVim_force" = "x-y"; then
        _local_old_dir=$(pwd)
        cd "$localPath"
        git stash
        git reset --hard
        git pull
        git stash pop
        cd "$_local_old_dir"
    else
        rm -rf "$localPath"
        git clone -q --depth=1 "$_zf_githost/ZSaberLv0/zf_vimrc.vim" "$localPath"
    fi
    _local_old_dir=$(pwd)
    cd "$localPath"
    git config core.filemode false
    cd "$_local_old_dir"

    localPathAbs=$(cd -- "$localPath" && pwd)
    if test -e "$localPathAbs/zfvim/zfvim" ; then
        chmod +x "$localPathAbs/zfvim/zfvim"
        chmod +x "$localPathAbs/zfvim/zfnvim"
        zf_vim_githost_setup "$localPathAbs/.zfvim/.vim/ZFVimModule/zf_githost.vim"
        zf_vim_install_plugin "$localPathAbs/zfvim/zfvim" "$localPathAbs/zfvim/zfnvim"
        echo ""
        echo "[ZFVim] installed locally, to add env:"
        echo "    export PATH=\$PATH:$localPathAbs/zfvim"
        echo "  or simply run:"
        echo "    ./$localPath/zfvim/zfvim"
        if ! test "x-$ZFVim_modules" = "x-y" ; then
            echo "  (optional) run ':ZFModuleInstall' to install additional tools such as LSPs"
        fi
    fi
    exit
fi


# ============================================================
# begin install
_old_dir=$(pwd)
cd "$HOME"

# ============================================================
# clean
if test "x-$ZFVim_force" = "x-y" ; then
    rm -f "./.vimrc" >/dev/null 2>&1
    rm -f "./_vimrc" >/dev/null 2>&1
    rm -f "./.vim" >/dev/null 2>&1
    rm -f "./.vim_cache" >/dev/null 2>&1
    rm -f "./.config/nvim/init.vim" >/dev/null 2>&1
fi

# ============================================================
# install action
zf_vim_install () {
    _vimrc=$1
    _exist=0
    grep -wq "zf_vimrc.vim" "$_vimrc" >/dev/null 2>&1 && _exist=1 || _exist=0

    if test "x-$_exist" = "x-0"; then
        _parent=${_vimrc%[/\\]*}
        if ! test -e "$_parent" && ! test "x-$_vimrc" = "x-$_parent" ; then
            mkdir -p "$_parent"
        fi
        echo "" >> "$_vimrc"

        echo "\" ========== added by zf_vimrc.vim ==========" >> "$_vimrc"

        echo "\" * for Cygwin users, if any weird problem occurred, uncomment one of these:" >> "$_vimrc"
        echo "\"" >> "$_vimrc"
        echo "\"     set shell=cmd.exe" >> "$_vimrc"
        echo "\"     set shellcmdflag=/c" >> "$_vimrc"
        echo "\"" >> $_vimrc
        echo "\"     set shell=bash" >> "$_vimrc"
        echo "\"     set shellcmdflag=-c" >> "$_vimrc"
        _isCygwin=0
        uname | grep -iq "cygwin" && _isCygwin=1 || _isCygwin=0
        if test "x-$_isCygwin" = "x-1"; then
            echo "set shell=bash" >> "$_vimrc"
            echo "set shellcmdflag=-c" >> "$_vimrc"
        fi
        echo "" >> "$_vimrc"

        echo "\" * after installed, press z? to view quick tutorial, enjoy" >> "$_vimrc"
        echo "" >> "$_vimrc"

        echo "source \$HOME/zf_vimrc.vim" >> "$_vimrc"
        echo "\" ---------- added by zf_vimrc.vim ----------" >> "$_vimrc"
        echo "" >> "$_vimrc"
        echo "" >> "$_vimrc"
    fi
}

zf_vim_githost_setup ".vim/ZFVimModule/zf_githost.vim"

# ============================================================
# vimrc
_vimrc=
if test -e ".vimrc"; then
    _vimrc=".vimrc"
elif test -e "_vimrc"; then
    _vimrc="_vimrc"
else
    _vimrc=".vimrc"
fi
zf_vim_install $_vimrc

# ============================================================
# neovim
if test "x-$_nvim_exist" = "x-1" && test "x-$ZFVim_neovim" = "x-y" ; then
    _nvimrc=".config/nvim/init.vim"
    _nvim_exist=0
    if test -e "$_nvimrc"; then
        grep -wq "zf_vimrc.vim" "$_nvimrc" >/dev/null 2>&1 && _nvim_exist=1 || _nvim_exist=0
    fi
    if test "x-$_nvim_exist" = "x-0" ; then
        zf_vim_install $_nvimrc
    fi
fi

# ============================================================
# git update
echo "[ZFVim] updating zf_vimrc..."
if test -e "./.zf_vimrc.vim/zf_vimrc.vim" ; then
    cp "./.zf_vimrc.vim/zf_vimrc.vim" "zf_vimrc.vim"
else
    _tmpdir="_zf_vimrc_tmp_"
    git clone -q --depth=1 "$_zf_githost/ZSaberLv0/zf_vimrc.vim" "$_tmpdir"
    cp "$_tmpdir/zf_vimrc.vim" "zf_vimrc.vim"
    rm -rf "$_tmpdir" >/dev/null 2>&1
fi

cd "$_old_dir"

zf_vim_install_plugin $ZF_VIM nvim

echo "[ZFVim] install finished"
if ! test "x-$ZFVim_modules" = "x-y" ; then
    echo "  (optional) run ':ZFModuleInstall' to install additional tools"
fi

