vim.cmd [[
augroup my_ftdetect
  autocmd BufNewFile,BufRead *.do   set filetype=tcl
  autocmd BufNewFile,BufRead *.xdc  set filetype=tcl
  autocmd BufNewFile,BufRead *.vh   set filetype=verilog
augroup END
]]
