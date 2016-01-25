if exists("g:loaded_clear_bufs")
  finish
endif
let g:loaded_clear_bufs = 1

let s:save_cpo = &cpo
set cpo&vim

command! -bang ClearBufs :call <SID>ClearBufsInner("<bang>")

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

let &cpo = s:save_cpo
unlet s:save_cpo
