vim.g.tagbar_left = 1
vim.g.tagbar_width = 32
vim.g.tagbar_compact = 1
vim.g.tagbar_sort = 0
vim.g.typescript_use_builtin_tagbar_defs = 0
vim.g.tagbar_type_cpp = {
  kinds      = {
    'c:classes:0:1',
    'd:macros:0:1',
    'e:enumerators:0:0',
    'f:functions:0:1',
    'g:enumeration:0:1',
    'l:local:0:1',
    'm:members:0:1',
    'n:namespaces:0:1',
    'p:functions_prototypes:0:1',
    's:structs:0:1',
    't:typedefs:0:1',
    'u:unions:0:1',
    'v:global:0:1',
    'x:external:0:1'
  },
  sro        = '::',
  kind2scope = {
    g = 'enum',
    n = 'namespace',
    c = 'class',
    s = 'struct',
    u = 'union'
  },
  scope2kind = {
    enum      = 'g',
    namespace = 'n',
    class     = 'c',
    struct    = 's',
    union     = 'u',
  }
}
vim.keymap.set('n', '<leader>w', ':TagbarToggle<CR>', { noremap = true })

