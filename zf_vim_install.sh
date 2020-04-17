#!bash

# ============================================================
# global check
_git_exist=0
git --version >/dev/null 2>&1 && _git_exist=1 || _git_exist=0
if test "x$_git_exist" = "x0"; then
    echo "error: git not installed"
    exit
fi

_vim_exist=0
vim --version >/dev/null 2>&1 && _vim_exist=1 || _vim_exist=0
_nvim_exist=0
nvim --version >/dev/null 2>&1 && _nvim_exist=1 || _nvim_exist=0
if test "x$_vim_exist" = "x1" ; then
    ZF_VIM=vim
elif test "x$_nvim_exist" = "x1" ; then
    ZF_VIM=nvim
else
    echo "error: vim or nvim not installed"
    exit
fi

_old_dir=$(pwd)
cd ~

# ============================================================
# clean
if test "x$ZF_force" = "x1" ; then
    rm -f "~/.vimrc" >/dev/null 2>&1
    rm -f "~/_vimrc" >/dev/null 2>&1
    rm -f "~/.vim" >/dev/null 2>&1
    rm -f "~/.vim_cache" >/dev/null 2>&1
    rm -f "~/.config/nvim/init.vim" >/dev/null 2>&1
fi

# ============================================================
# install action
zf_vim_install () {
    _vimrc=$1
    _exist=0
    grep -wq "zf_vimrc.vim" "$_vimrc" >/dev/null 2>&1 && _exist=1 || _exist=0

    if test "x$_exist" = "x0"; then
        _parent=${_vimrc%[/\\]*}
        if ! test -e "$_parent" && ! test "x$_vimrc" = "x$_parent" ; then
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
        if test "x$_isCygwin" = "x1"; then
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
if test "x$_nvim_exist" = "x1" && test "x$ZF_neovim" = "x" ; then
    ZF_neovim=1
fi
if test "x$ZF_neovim" = "x1" ; then
    _nvimrc=".config/nvim/init.vim"
    _nvim_exist=0
    if test -e "$_nvimrc"; then
        grep -wq "zf_vimrc.vim" "$_nvimrc" >/dev/null 2>&1 && _nvim_exist=1 || _nvim_exist=0
    fi
    if test "x$_nvim_exist" = "x0" ; then
        zf_vim_install $_nvimrc
    fi
fi

# ============================================================
# git update
git config --global core.autocrlf false

echo "updating zf_vimrc..."
_tmpdir="_zf_vimrc_tmp_"
git clone --depth=1 https://github.com/ZSaberLv0/zf_vimrc.vim.git "$_tmpdir"
cp "$_tmpdir/zf_vimrc.vim" "zf_vimrc.vim"
rm -rf "$_tmpdir" >/dev/null 2>&1

cd "$_old_dir"

# ============================================================
# install plugins
$ZF_VIM +ZFPlugAutoUpdateMarkFinish +PlugClean! +PlugUpdate +qall </dev/tty

# nvim may have different plugins, update again
if test "x$_vim_exist" = "x1" && test "x$_nvim_exist" = "x1" ; then
    nvim +PlugInstall +qall </dev/tty
fi

# try to install external tools
if test ! "x$ZF_modules" = "x0" ; then
    $ZF_VIM +ZFModuleInstall +qall </dev/tty
fi

