" Align C-style declarations so the names line up in one column.
" Works on variables and function prototypes. Pointer stars hang to the left
" of the name column:
"
"     GLuint               vao;
"     RenderSpriteVertex  *vertices;
"
"     static void         ExpandSprite(Render *render);
"     static RenderSprite RenderSprite_CreateFromRect(S32Rect rect);
"
" Each run of consecutive declaration lines is aligned on its own, so blank
" lines (or any line that isn't a declaration) start a new group.

" spaces between the longest type (plus its stars) and the name column
let g:aligndecl_gap = get(g:, 'aligndecl_gap', 2)
" same, for groups containing function prototypes
let g:aligndecl_func_gap = get(g:, 'aligndecl_func_gap', 1)

" indent, type, separator (whitespace and/or stars), name, rest (; = [ , : ()
let s:decl = '^\(\s*\)\(.\{-}\S\)\(\s\+\**\s*\|\s*\*\+\s*\)\(\h\w*\)\(\s*[;=[,:(].*\)$'

function! aligndecl#Align(first, last) abort
    let l:group = []
    for l:lnum in range(a:first, a:last)
        let l:m = matchlist(getline(l:lnum), s:decl)
        if empty(l:m)
            call s:AlignGroup(l:group)
            let l:group = []
            continue
        endif
        let l:rest = substitute(l:m[5], '\s\+$', '', '')
        call add(l:group, {
            \ 'lnum':  l:lnum,
            \ 'head':  l:m[1] . l:m[2],
            \ 'stars': substitute(l:m[3], '[^*]', '', 'g'),
            \ 'tail':  l:m[4] . substitute(l:rest, '^\s\+\ze[;,[(]', '', ''),
            \ 'func':  l:rest =~# '^\s*(',
            \ })
    endfor
    call s:AlignGroup(l:group)
endfunction

function! s:AlignGroup(group) abort
    if empty(a:group)
        return
    endif
    let l:width = 0
    let l:stars = 0
    let l:func = 0
    for l:d in a:group
        let l:width = max([l:width, strdisplaywidth(l:d.head)])
        let l:stars = max([l:stars, len(l:d.stars)])
        let l:func = l:func || l:d.func
    endfor
    let l:col = l:width + (l:func ? g:aligndecl_func_gap : g:aligndecl_gap) + l:stars
    for l:d in a:group
        let l:pad = l:col - strdisplaywidth(l:d.head) - len(l:d.stars)
        call setline(l:d.lnum, l:d.head . repeat(' ', l:pad) . l:d.stars . l:d.tail)
    endfor
endfunction
