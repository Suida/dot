vim.g.startify_disable_at_vimenter = 1
vim.g.startify_session_persistence = 1
vim.g.startify_session_delete_buffers = 1
vim.g.startify_session_before_save = {
  'silent! NvimTreeClose',
  'let g:startify_tmp_tabpagenr = tabpagenr()',
  'let g:startify_tmp_winnr = winnr()',
  'echo "Cleaning up before saving.."',
  'silent! tabdo NvimTreeClose',
  'lua require("codecompanion").close_last_chat()',
  'execute "normal! " . g:startify_tmp_tabpagenr . "gt"',
  'execute g:startify_tmp_winnr . "wincmd w"'
}
vim.g.startify_lists = {
  { type='sessions',  header= {'   Sessions'}       },
  { type='bookmarks', header= {'   Bookmarks'}      },
  { type='commands',  header= {'   Commands'}       },
}
-- autocmd VimEnter * call init_startify()
vim.cmd [[
augroup startify_stuff
autocmd BufEnter * let &titlestring=fnamemodify(v:this_session, ':t')
augroup END
]]
vim.g.init_startify = function()
  if not vim.fn.argc() then
    vim.cmd [[
    Startify
    NvimTreeOpen
    sleep 100m
    wincmd w
    ]]
  end
end

vim.g.startify_custom_header = vim.fn['startify#pad'](vim.fn['startify#fortune#boxed']())
