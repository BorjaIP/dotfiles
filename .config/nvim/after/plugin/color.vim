" ColorScheme
function s:CheckColorScheme()

    syntax on                   " Enable syntax highligh
    set termguicolors           " Enable 24 bit color

    let s:config_file = expand('~/.config/nvim/.base16')

    if filereadable(s:config_file)
        let s:config = readfile(s:config_file, '', 2)

        if s:config[1] =~# '^dark\|light$'
            execute 'set background=' . s:config[1]
        else
            echoerr 'Bad background ' . s:config[1] . ' in ' . s:config_file
        endif

        if filereadable(expand('~/.config/nvim/plugged/base16-vim/colors/base16-' . s:config[0] . '.vim'))
            execute 'color base16-' . s:config[0]
        else
            echoerr 'Bad scheme ' . s:config[0] . ' in ' . s:config_file
        endif
    else " default color
        set background=dark
        " color base16-material-darker
        color base16-ocean
    endif

    doautocmd ColorScheme
    let g:base16colorspace=256  " Enable 256 suppport for base16
endfunction

if v:progname !=# 'vi'
    if has('autocmd')
        augroup WincentAutocolor
            autocmd!
            autocmd FocusGained * call s:CheckColorScheme()
        augroup END
    endif

    call s:CheckColorScheme()
endif
