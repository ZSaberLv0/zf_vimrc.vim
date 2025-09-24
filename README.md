<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
    * [Directory Structure](#directory-structure)
    * [Directory Structure (Portable Mode)](#directory-structure-portable-mode)
* [Install](#install)
    * [Quick Install](#quick-install)
        * [Portable Mode](#portable-mode)
        * [Windows gVimPortable](#windows-gvimportable)
        * [Install Settings](#install-settings)
    * [Manual Install](#manual-install)
    * [Uninstall](#uninstall)
        * [non-Portable Mode](#non-portable-mode)
        * [Portable Mode](#portable-mode-1)
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

portable, powerful yet lightweight vimrc config for vim/neovim

main feature:

* cross platform, and keep similar user experience for these platforms
* low dependency, no anoying lag or errors for old versions and envs
* can be installed completely portable, best for servers
* powerful for general usage


should work, for almost all of real vim envs:

* vim 7.3 or above
* neovim 0.3 or above
* Windows's gVim
* cygwin's vim
* Mac OS's vim and macvim (console or GUI)
* Ubuntu's vim
* Android's DroidVim

may work, on vim simulation envs: (search and see `g:zf_fakevim`)

* IntelliJ IDEA's IdeaVim (good to use)
* Qt Creator's FakeVim (able to use)
* VisualStudio's VsVim (able to use)
* XCode's XVim (not recommended)


if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins,
or [buy me a coffee](https://github.com/ZSaberLv0/ZSaberLv0)


## Directory Structure

```
~/
    .vim/
        bundle/                 // all plugins placed here
        ZFVimModule/            // (optional) you may supply all your custom setting here
                                //     *.vim under this dir would be sourced automatically
                                //     files are ensured to be sourced by name order

            zf_vimrc.ext/       // (optional, but installed by default)
                                //     contains useful but heavy dependencies, such as LSPs

            vimrc.local.vim     // (optional) your custom local setting for current machine
            YourGitRepo/        // (optional) your custom module
                ZFInit/         //     sourced during init
                ZFPlugPrev/     //     sourced just after `vim-plug`'s `plug#begin()`
                ZFPlugPost/     //     sourced just before `vim-plug`'s `plug#end()`
                ZFFinish/       //     sourced after all other source
    .vim_cache/                 // cache files of this repo
    .vimrc                      // vim's default config file
    zf_vimrc.vim                // this repo's main config file
```

the location of files installed by this config,
can be configured by:

```
let g:zf_vim_data_path=$HOME . '/.vim'
let g:zf_vim_cache_path=$HOME . '/.vim_cache'
```

## Directory Structure (Portable Mode)

you may even use this repo completely portable (see `Portable Mode` below),
with this directory structure:

```
any_path/
    zf_vimrc.vim/                   // this repo's root
        .zfvim/                     // all config files generated here
            .vim/
                bundle/             // all plugins
                ZFVimModule/        // optional modules
            .vim_cache/             // cache files
        zfvim/                      // entry script to start with
            zfvim
            zfnvim
        zf_vimrc.vim                // this repo's main config file
```


# Install

## Quick Install

if you have `curl`, `git`, `vim` installed, here's a very simple command to install everything:

```
curl zsaber.com/vim | sh

# or, copy the `zf_vim_install.sh` to anywhere and then simply run it
sh zf_vim_install.sh
```

once installed, you may press `z?` to view a quick tutorial for this config


### Portable Mode

if you just want to quickly test this repo,
or prefer run from portable disks:

* use the Quick Install script `curl zsaber.com/vim | sh`

    the script would prompt for some install options,
    when you get this:

    ```
    [ZFVim] install locally? [n/y/path_to_install]:
    ```

    input `y` or any path (such as `./zf_vimrc.local`)
    would make it install to the specified local dir,
    and you may use the util script to launch:

    ```
    ./zf_vimrc.local/zfvim/zfvim
    ```

* install manually

    ```
    # clone this repo
    git clone https://github.com/ZSaberLv0/zf_vimrc.vim

    # ensure it's executable
    chmod +x ./zf_vimrc.vim/zfvim/zfvim

    # simply run from util script
    ./zf_vimrc.vim/zfvim/zfvim
    ```


### Windows gVimPortable

for lazy ones, here's a packaged portable version of gVim for Windows: [Download](https://pan.baidu.com/s/1nt3NJhJ)

it's not ensured keep update with this repo, but you may use `<leader>vimru` to update


### Install Settings

you may use `export ZFVim_xxx=yyy` before `curl zsaber.com/vim | sh` to make it active,
or, by default, the quick install script would prompt for these options

* `ZFVim_githost` : git host

    default: empty for `https://github.com`

    useful mirrors:

    * `https://hub.fastgit.org`
    * `https://github.com.cnpmjs.org`

* `ZFVim_local` : `[n/y/path_to_install]` whether install locally

    default: n

    * when `ZFVim_local=y`, try to install to `./zf_vimrc.local`
    * otherwise, when not empty, try to install to `./$ZFVim_local`

    when installed locally, all files are placed under the specified dir
    (see `Directory Structure` above),
    it's convenient to test this repo without messed up your own,
    or use as portable config on server or USB devices

    to use the local version, use `path/to/zf_vimrc.local/zfvim/zfvim`,
    or `export PATH=$PATH:path_to_zfvim` for convenient

    by default, the portable `zfvim` would work as "full" version,
    which would disable huge plugins such as LSPs,
    and here's all the versions:

    * `zfvim` : same as `zfvim --full`
    * `zfvim --full` : full version
    * `zfvim --mini` : mini version with LSPs disabled
    * `zfvim --tiny` : tiny version with all plugins disabled

* `ZFVim_force` : `[n/y]` remove all contents and perform clean install

    default: n

    these items would be removed before install

    ```
    ~/.vimrc
    ~/_vimrc
    ~/.vim
    ~/.config/nvim/init.vim
    ```

* `ZFVim_modules` : `[n/y]` whether try to install external command line tools

    default: n

* `ZFVim_neovim` : `[y/n]` also install to neovim, which would add `source ~/zf_vimrc.vim`
    to `~/.config/nvim/init.vim`

    default: y if `nvim` exist in your shell


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

### non-Portable Mode

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

### Portable Mode

to uninstall, simply remove the generated dir,
which is `./zf_vimrc.local` by default


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

this config is fully modularized, it's recommended to supply your own setting in `~/.vim/ZFVimModule`:

```
~/
    .vim/
        ZFVimModule/
            vimrc.local.vim     // recommended to supply platform-dependent settings for local machine
            YourGitRepo1/       // you may supply extra config as git repo,
                                //   with specified directory structure
                ZFInit/         // sourced during init,
                                //   config for `zf_vimrc.vim` itself can be placed here,
                                //   for example `let g:ZF_Plugin_agit = 0` to disable builtin plugin
                    a.vim       // all *.vim files would be sourced,
                    b.vim       //   and are ensured ordered by file name
                ZFPlugPrev/     // sourced just after `plug#begin()`,
                                //   you may add your own plugin here,
                                //   for example: `ZFPlug 'UserName/PlugName'`
                ZFPlugPost/     // sourced just before `plug#end()`
                ZFFinish/       // sourced after all other source,
                                //   can be used to override some config of `zf_vimrc.vim`
            YourGitRepo2/       // you may supply any number of extra config
                ZFInit/
                ZFPlugPrev/
                ZFPlugPost/
                ZFFinish/
```

see [zf_vimrc.ext](https://github.com/ZSaberLv0/zf_vimrc.ext) for example


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
* you should manually copy all settings from other platform to DroidVim's folder,
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
let g:zf_fakevim = 1
source path/to/zf_vimrc.vim
```

* not fully tested
* some vim simulation plugins doesn't support `source` command,
  so you may need to paste directly to proper vimrc files (e.g. `.xvimrc`)
* some vim simulation plugins doesn't support `if-statement` and plugins,
  so you may need to manually delete all lines under the `if g:zf_no_plugin!=1` section


### IdeaVim

recommended to:

* (for MacOS only) `defaults write -g ApplePressAndHoldEnabled 0`
* install `IdeaVim-EasyMotion` and `AceJump` plugin (within your IDE's plugin manager)
* add these configs to your `~/.ideavimrc`

    ```
    let mapleader="'"
    let g:zf_fakevim=1
    source ~/zf_vimrc.vim

    nnoremap <esc> <esc>:action HideActiveWindow<cr>
    nmap <c-o> :action SearchEverywhere<cr>
    nmap zu :action GoToErrorGroup<cr>
    nmap zi :action ShowIntentionActions<cr>
    nmap zo :action OverrideMethods<cr>
    nmap X :action CloseAllEditorsButActive<cr>
    nmap H :action PreviousTab<cr>
    nmap L :action NextTab<cr>
    nmap CC :action CommentByLineComment<cr><up>
    xmap CC :action CommentByLineComment<cr><esc>
    nmap t :action EditorSelectWord<cr>
    xmap t :action EditorSelectWord<cr>
    nmap T :action EditorUnSelectWord<cr>
    xmap T :action EditorUnSelectWord<cr>

    nmap DB :action ToggleLineBreakpoint<cr>
    nmap DV :action ViewBreakpoints<cr>
    nmap DC :action ViewBreakpoints<cr>
    nmap DF :action ShowHoverInfo<cr>
    nmap <f4> :action Stop<cr>
    nmap <f5> :action Debug<cr>
    nmap DS :action Resume<cr>
    nmap Ds :action Pause<cr>
    nmap DU :action StepOut<cr>
    nmap <f9> :action StepOut<cr>
    nmap DO :action StepOver<cr>
    nmap <f10> :action StepOver<cr>
    nmap DI :action StepInto<cr>
    nmap <f11> :action StepInto<cr>

    set NERDTree
    nmap <leader>ve :NERDTreeToggle<cr>
    nmap <leader>ze :NERDTreeFind<cr>

    set easymotion
    nmap s <plug>(easymotion-s)
    xmap s <plug>(easymotion-s)
    nmap S <plug>(easymotion-bd-jk)
    xmap S <plug>(easymotion-bd-jk)
    let g:EasyMotion_startofline = 1

    set surround
    let g:surround_no_mappings = 1
    nmap rd <plug>DSurround
    nmap RD <plug>DSurround
    nmap rc <plug>CSurround
    nmap RC <plug>CSurround
    xmap r <plug>VSurround
    xmap R <plug>VSurround
    ```

