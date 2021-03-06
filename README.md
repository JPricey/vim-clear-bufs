# Clear Bufs #

Helpers for unloading buffers.

## Usage ##

`:ClearBufs[!]`

Unload all inactive buffers (buffers which are not in any windows).
Append `!` to delete modified buffers.

`:ClearCurrent[!]`

Unload the current buffer.
All windows with the current buffer open will try to switch to the alternate buffer if it is loaded.
If there is no alternate buffer, or it is not loaded, the window will try to open the next listed buffer.
If that doesn't exist either, they will fallback to a new empty buffer.
Append `!` to exit modified buffers.

`:ClearSwapLoaded[!]`
An alternative to `<C-^>` which will try to switch to the alternate buffer if it is loaded.
If there is no alternate buffer, or it is not loaded, the window will try to open the next listed buffer.
Append `!` to leave a modified buffer if `hidden` is not set.
