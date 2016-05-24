if exists('g:loaded_clear_bufs')
  finish
endif
let g:loaded_clear_bufs = 1

let s:save_cpo = &cpo
set cpo&vim

command! -bang ClearBufs :call <SID>ClearBufsInner('<bang>')
command! -bang ClearCurrent :call <SID>ClearCurrentInner('<bang>')
command! -bang ClearSwapLoaded :call <SID>ClearSwapLoadedInner('<bang>')

function! <SID>ClearBufsInner(bang)
  let activeBufs = {}

  " Create map of all active buffers
  let i = 1
  while 1
    let bufNum = winbufnr(i)
    if bufNum == -1
      break
    endif
    let activeBufs[bufNum] = 0
    let i = i + 1
  endwhile

  " Delete all inactive buffers
  let numDeleted = 0
  let lastBufNum = bufnr('$')
  let i = 1
  while i <= lastBufNum
    if buflisted(i) && get(activeBufs, i, 1)
      silent execute 'bdelete' . a:bang . ' ' . i
      if !buflisted(i)
        let numDeleted = numDeleted + 1
      endif
    endif
    let i = i + 1
  endwhile

  if numDeleted == 1
    echomsg 'Deleted 1 buffer.'
  elseif numDeleted > 1
    echomsg 'Deleted ' . numDeleted . ' buffers.'
  endif
endfunction

function! <SID>ClearCurrentInner(bang)
  let targetBuf = bufnr('%')
  let bufWindows = []

  " Find all windows that have the current buffer open
  let i = 1
  while 1
    let bufNum = winbufnr(i)
    if bufNum == -1
      break
    elseif bufNum == targetBuf
      call add(bufWindows, i)
    endif
    let i = i + 1
  endwhile

  let fallbackBuf = <SID>GetFallbackBuffer(targetBuf)

  let startWindow = winnr()

  if !&modified || a:bang == '!'
    for winIndex in bufWindows
      exe winIndex . 'wincmd w'
      if !(<SID>ClearTrySwap(a:bang))
        if fallbackBuf <= 0
          exe 'enew' . a:bang
          let fallbackBuf = bufnr('%')
        else
          exe 'buffer' . a:bang . ' ' . fallbackBuf
        endif
      endif
    endfor

    exe startWindow . 'wincmd w'
  endif

  silent execute 'bdelete' . a:bang . ' ' . targetBuf
endfunction

function! <SID>GetFallbackBuffer(exceptBuf)
  let fallbackBuf = bufnr('$')

  while fallbackBuf > 0
    if fallbackBuf != a:exceptBuf && buflisted(fallbackBuf)
      break
    endif
    let fallbackBuf = fallbackBuf - 1
  endwhile

  return fallbackBuf
endfunction

function! <SID>ClearTrySwap(bang)
  let swapBuf = bufnr('#')
  if swapBuf == -1
    return 0
  endif

  if buflisted(swapBuf)
    exe 'buffer' . a:bang . ' ' . swapBuf
    return 1
  else
    return 0
  endif
endfunction

function! <SID>ClearSwapLoadedInner(bang)
  if <SID>ClearTrySwap(a:bang)
    return 1
  endif

  let fallbackBuf = <SID>GetFallbackBuffer(bufnr('%'))

  if fallbackBuf > 0
    exe 'buffer' . a:bang . ' ' . fallbackBuf
    return 1
  else
    return 0
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
