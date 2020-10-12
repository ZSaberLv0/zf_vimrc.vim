<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
    * [Directory Structure](#directory-structure)
* [Install](#install)
    * [Quick Install](#quick-install)
        * [Windows gVimPortable](#windows-gvimportable)
        * [Install Settings](#install-settings)
    * [Manual Install](#manual-install)
    * [Uninstall](#uninstall)
    * [Additional Requirement](#additional-requirement)
* [Customizing](#customizing)
* [Platform Spec](#platform-spec)
    * [Complete Engines and LSPs](#complete-engines-and-lsps)
    * [MacOS ssh](#macos-ssh)
    * [Cygwin](#cygwin)
    * [Android](#android)
        * [DroidVim (recommended)](#droidvim-recommended)
        * [VimTouch](#vimtouch)
    * [For simulation plugins of IDE](#for-simulation-plugins-of-ide)
        * [IdeaVim](#ideavim)

<!-- vim-markdown-toc -->

# Introduction

my personal vimrc config for vim

main purpose:

* cross platform, and keep similar user experience for these platforms
* low dependency, no anoying lag or errors for old versions and envs
* powerful for general usage


tested:

* vim version 7.3 or above
* neovim version 0.1 or above
* Windows's gVim
* cygwin's vim
* Mac OS's vim and macvim (console or GUI)
* Ubuntu's vim
* Android's DroidVim

may work: (search and see `g:zf_fakevim`)

* Qt Creator's FakeVim (able to use, some keymap doesn't work)
* IntelliJ IDEA's IdeaVim (able to use, some keymap doesn't work)
* VisualStudio's VsVim (able to use, some keymap doesn't work, require `let g:zf_fakevim=1`)
* XCode's XVim (not recommended, some action have unexpected behavior)


for me, I use this config mainly for `C/C++` `markdown` `typescript` `PHP` development,
as well as for default text editor and log viewer


## Directory Structure

```
~/
    .vim/
        bundle/                 // all plugins placed here
        ZFVimModule/            // (optional) you may supply all your custom setting here
                                // *.vim under this dir would be sourced automatically
                                // files are ensured to be sourced by name order
            vimrc.local.vim     // (optional) local setting for current machine
            YourGitRepo/
                ZFInit/         //     called during init
                ZFPlugPrev/     //     called just after `vim-plug`'s `plug#begin()`
                ZFPlugPost/     //     called just before `vim-plug`'s `plug#end()`
                ZFFinish/       //     called after all other source
    .vimrc                      // vim's default config file
    zf_vimrc.vim                // this repo's main config file
```

the location of files installed by this config,
can be configured by:

```
let g:zf_vim_data_path=$HOME . '/.vim'
let g:zf_vim_cache_path=$HOME . '/.vim_cache'
```


# Install

## Quick Install

if you have `curl`, `git`, `vim` installed, here's a very simple command to install everything:

```
curl zsaber.com/vim | sh
```

```
# or, run the install script directly
sh zf_vim_install.sh

# optionally, change install settings (listed below) before running the shell script
export ZF_xxx=1
curl zsaber.com/vim | sh
```

<b>once installed, you may press `z?` to view a quick tutorial for this config</b>


### Windows gVimPortable

for lazy ones, here's a packaged portable version of gVim for Windows: [Download](https://pan.baidu.com/s/1nt3NJhJ)

it's not ensured keep update with this repo, but you may use `<leader>vimru` to update


### Install Settings

* `ZF_force` : remove all contents and perform clean install

    default: 0

    these items would be removed before install

    ```
    ~/.vimrc
    ~/_vimrc
    ~/.vim
    ~/.config/nvim/init.vim
    ```

* `ZF_neovim` : also install to neovim, which would add `source ~/zf_vimrc.vim`
    to `~/.config/nvim/init.vim`

    default: 1 if `nvim` exist in your shell


## Manual Install

1. ensure `git` are available in your `PATH`
1. download or clone the `zf_vimrc.vim` file to anywhere
1. have these in your `.vimrc` (under linux) or `_vimrc` (under Windows):

    ```
    source path/zf_vimrc.vim
    ```

1. open your vim, plugins should be installed automatically

for a list of plugins and configs, please refer to the
[zf_vimrc.vim](https://github.com/ZSaberLv0/zf_vimrc.vim/blob/master/zf_vimrc.vim) itself,
which is self described


## Uninstall

to uninstall, remove these lines in your `.vimrc` and `.config/nvim/init.vim`

```
source path/zf_vimrc.vim
```

and remove these dirs/files if exists

```
$HOME/.vim
$HOME/.vim_cache
$HOME/zf_vimrc.vim
```


## Additional Requirement

* [cygwin](https://www.cygwin.com)

    not necessary, but strongly recommended for Windows users

* GNU grep (greater than 2.5.3)

    for [vim-easygrep](https://github.com/dkprice/vim-easygrep) if you want to use Perl style regexp

    note the FreeBSD version won't work due to the lack of `-P` option of `grep`

* external command line tools

    you may use `:ZFModuleInstall` to install other additional external command line tools,
    this may take a long time


# Customizing

1. it's recommended to modify platform-dependent settings in `.vimrc` or `~/.vim/ZFVimModule/vimrc.local.vim`, such as:

    ```
    au GUIEnter * simalt ~x
    set guifont=Consolas:h12
    set termencoding=cp936
    let g:zf_colorscheme_256=1
    source path/zf_vimrc.vim
    ```

* all builtin plugins can be disabled by adding this before `source zf_vimrc.vim`

    ```
    let g:ZF_Plugin_agit=0
    ```

* to add your own plugin, add this before `source zf_vimrc.vim`

    ```
    function! MyPlugSetting()
        ZFPlug 'username/your_plugin1_name'
        let your_plugin1_config=xxx
        ZFPlug 'username/your_plugin2_name'
        let your_plugin2_config=yyy
    endfunction
    autocmd User ZFVimrcPlug call MyPlugSetting()
    ```


# Platform Spec

## Complete Engines and LSPs

usually, complete engines have heavy dependencies and hard to config,
so we separate these configs to [zf_vimrc.ext](https://github.com/ZSaberLv0/zf_vimrc.ext)
to make this repo simple and clean,
the `zf_vimrc.ext` would also be installed by default,
but you should go [zf_vimrc.ext/README.md](https://github.com/ZSaberLv0/zf_vimrc.ext/blob/master/README.md)
for how to properly setup LSPs


## MacOS ssh

when used under ssh of some new version of MacOS, you may get some weird error message,
that's because the default shell was changed to `zsh`
and it does not properly set `$LANG`,
to solve this, add this line to your `~/.zprofile` or `~/.zshrc`

```
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
```


## Cygwin

when used under different version of cygwin, you should concern these settings if weird problem occurred:

```
set shell=cmd.exe
set shellcmdflag=/c
```

or

```
set shell=bash
set shellcmdflag=-c
```

set it directly to `.vimrc`, choose the right one for you


## Android

### DroidVim (recommended)

* the vim config is placed under `/data/data/com.droidvim/files/home/.vimrc`
* you should manually copy all settings from other platform to VimTouch's folder,
    the result folder tree should looks like:

    ```
    /data/data/com.droidvim/files/home/
        .vim/
            bundle/
                ...
        .vimrc
        zf_vimrc.vim
    ```


### VimTouch

* `VimTouch Full Runtime` is also required
* the vim config is placed under `/data/data/net.momodalo.app.vimtouch/files/.vimrc`
* you should manually copy all settings from other platform to VimTouch's folder,
    the result folder tree should looks like:

    ```
    /data/data/net.momodalo.app.vimtouch/files/
        .vim/
            bundle/
                ...
        .vimrc
        zf_vimrc.vim
    ```

**Note: VimTouch's vimrc may or may not be sourced under Android 5 or above, reason unknown,
    this is VimTouch's problem, not this repo's problem**


## For simulation plugins of IDE

```
let g:zf_fakevim=1
```

* not fully tested
* some vim simulation plugins doesn't support `source` command,
  so you may need to paste directly to proper vimrc files (e.g. `.ideavim`, `.xvimrc`)
* some vim simulation plugins doesn't support `if-statement` and plugins,
  so you may need to manually delete all lines under the `if g:zf_no_plugin!=1` section


### IdeaVim

recommended to:

* install `IdeaVim-EasyMotion` plugin (within your IDE's plugin manager)
* add these configs to your `~/.ideavimrc`

    ```
    let g:zf_fakevim=1
    source ~/zf_vimrc.vim

    nmap <c-o> :action SearchEverywhere<cr>

    set easymotion
    nmap s <plug>(easymotion-s)
    xmap s <plug>(easymotion-s)
    nmap S <plug>(easymotion-bd-jk)
    xmap S <plug>(easymotion-bd-jk)
    let g:EasyMotion_startofline = 1

    set surround
    nmap rd ds
    nmap RD ds
    nmap rc cs
    nmap RC cs
    xmap r S
    xmap R S

    set commentary
    nmap CC gcc
    xmap CC gcc
    ```

