
let g:zf_no_ext = 1
let g:zf_no_submodule = 1
let g:zf_no_plugin = 1
execute 'source ' . substitute(fnamemodify(expand('<sfile>'), ':h') . '/.zfvim_base.vim', ' ', '\\ ', 'g')

