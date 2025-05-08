local cmp_status_ok, cmp = pcall(require, 'cmp')
local cmp_autopairs_ok, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')

if not cmp_status_ok or not cmp_autopairs_ok then
  return
end

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)
