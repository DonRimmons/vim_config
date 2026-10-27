"""""""""""""""""""""""""""""""""""
" general config
"""""""""""""""""""""""""""""""""""
set termguicolors
set cscopeverbose
set cscopetag
set tabstop=4
set shiftwidth=4
set expandtab
set cindent
set backspace=indent,eol,start
set nobackup
set noundofile
set scrolloff=10
set nonumber
"set relativenumber
set path+=** " search down into subfolders (for tab-complete)
set wildmenu " display all matching files for tab-complete
set wrap!
"set autochdir
set formatoptions-=cro " disable auto commenting
set nrformats+=alpha " with CTRL+A
set splitbelow

filetype on
filetype plugin indent on

"""""""""""""""""""""""""""""""""""
" lsp
"""""""""""""""""""""""""""""""""""
autocmd User LspSetup call LspAddServer([#{
    \    name: 'clangd',
    \    filetype: ['c', 'cpp'],
    \    path: '/usr/bin/clangd',
    \    args: ['--background-index']
    \  }])

autocmd User LspSetup call LspOptionsSet(#{ showDiagWithSign: v:false, semanticHighlight: v:true })
set signcolumn=no

noremap <silent> <Leader>gd :LspGotoDefinition<CR>
noremap <silent> <Leader>gp :LspPeekDefinition<CR>
noremap <silent> <Leader>gr :LspShowReferences<CR>
noremap <silent> <Leader>gs :LspSymbolSearch<CR>
noremap <silent> <Leader>go :LspDocumentSymbol<CR>

"""""""""""""""""""""""""""""""""""
" fzf
"""""""""""""""""""""""""""""""""""
noremap <silent> <Leader>pf :Files<CR>
noremap <silent> <Leader>pb :Buffers<CR>
noremap <silent> <Leader>pg :Rg<CR>
noremap <silent> <Leader>pt :Tags<CR>

" vim does not like c11 sometimes
let c_no_bracket_error = 1

"""""""""""""""""""""""""""""""""""
" global variables
"""""""""""""""""""""""""""""""""""
let g:explore_is_open = 0
let g:quickfix_is_open = 0

"""""""""""""""""""""""""""""""""""
" functions
"""""""""""""""""""""""""""""""""""
function! ToggleExplore()
    if g:explore_is_open
        let g:explore_is_open = 0
        :Rexplore
    else
        let g:explore_is_open = 1
        :Explore
    endif
endfunction

function! ToggleQuickfix()
    if g:quickfix_is_open
        let g:quickfix_is_open = 0
        :cclose
    else
        let g:quickfix_is_open = 1
        :copen
    endif
endfunction

function! RunScript(script) abort
    let l:cwd_script = getcwd() . '/' . a:script
    let l:script_abs = filereadable(l:cwd_script) ? l:cwd_script : findfile(a:script, ';')

    if empty(l:script_abs)
        echo a:script . " not found"
        return
    endif

    let l:script_abs = fnamemodify(l:script_abs, ':p')
    let l:script_dir = fnamemodify(l:script_abs, ':h')
    let l:saved_cwd = getcwd()

    execute 'lcd ' . fnameescape(l:script_dir)
    let l:cmd = shellescape(l:script_abs) . ' 2>&1'
    let l:output = systemlist(l:cmd)
    " resolve qf entries' relative paths against script_dir before restoring cwd
    call setqflist([], ' ', {'title': a:script, 'lines': l:output})
    execute 'lcd ' . fnameescape(l:saved_cwd)

    copen
    let g:quickfix_is_open = 1
endfunction

syntax enable

" some colorschemes skip clearing old highlights before defining their own,
" so leftover groups from the previous scheme can bleed through
augroup ClearColorsBeforeSwitch
    autocmd!
    autocmd ColorSchemePre * highlight clear | if exists('syntax_on') | syntax reset | endif
augroup END

"let ayucolor="mirage"
"colorscheme None
"colorscheme PaperColor
"colorscheme ayu
"colorscheme borland
"colorscheme borlandp
"colorscheme dosbox
"colorscheme elflord
"colorscheme nord
"colorscheme retrobox
"colorscheme simple-dark
colorscheme codedark

" internal palette/base files some themes source but aren't real schemes to select
let g:colorscheme_blocklist = ['dracula_base']

function! CycleColorscheme(direction) abort
    let l:schemes = uniq(sort(map(globpath(&runtimepath, 'colors/*.vim', 0, 1), "fnamemodify(v:val, ':t:r')")))
    let l:schemes = filter(l:schemes, 'index(g:colorscheme_blocklist, v:val) == -1')
    let l:current = index(l:schemes, get(g:, 'colors_name', ''))
    let l:next = (l:current + a:direction) % len(l:schemes)
    if l:next < 0
        let l:next += len(l:schemes)
    endif
    execute 'colorscheme ' . l:schemes[l:next]
    redraw
    echohl ModeMsg
    echo 'colorscheme: ' . l:schemes[l:next] . ' (' . (l:next + 1) . '/' . len(l:schemes) . ')'
    echohl None
endfunction

noremap <silent> <Leader>] :call CycleColorscheme(1)<CR>
noremap <silent> <Leader>[ :call CycleColorscheme(-1)<CR>

set tags=./.tags;/

"""""""""""""""""""""""""""""""""""
" keyboard remappings
"""""""""""""""""""""""""""""""""""
if has('win32')
    noremap <silent> <Leader>b :call RunScript('build.bat')<CR>
    noremap <silent> <Leader>d :call RunScript('buildrun.bat')<CR>
    noremap <silent> <Leader>c :call RunScript('ctags.bat') "ctags completed"<CR>
    noremap <silent> <Leader>t :call RunScript('clang-format.bat') "clang-format completed"<CR>
else
    noremap <silent> <Leader>b :call RunScript('build.sh')<CR>
    noremap <silent> <Leader>d :call RunScript('buildrun.sh')<CR>
    noremap <silent> <Leader>c :call RunScript('ctags.sh') "ctags completed"<CR>
    noremap <silent> <Leader>t :call RunScript('clang-format.sh') "clang-format completed"<CR>
endif

noremap <silent> <Leader>v :so $MYVIMRC<CR>

" auto-indent entire file
noremap <silent> <leader>f gg=G<CR>

" show/hide explorer window
noremap <silent> <Leader>e :call ToggleExplore()<CR>
noremap <silent> <Leader>q :call ToggleQuickfix()<CR>
noremap <silent> <Leader>, :cp<CR>
noremap <silent> <Leader>. :cn<CR>

" autocompletion
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <CR>    pumvisible() ? "\<C-y>" : "\<CR>"

" Align entire file as CSV
vnoremap <leader>ca :>!column -t <CR>


" Align declarations so variable names line up (autoload/aligndecl.vim)
command! -range AlignDecl call aligndecl#Align(<line1>, <line2>)
xnoremap <silent> <Leader>a :AlignDecl<CR>
