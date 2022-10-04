local mappings = {
    list = {
        { key = "K",            action = "toggle_file_info" },
        { key = "t",            action = "tabnew" },
        { key = "<C-k>",        action = "" },
        { key = "<C-e>",        action = "" },
    },
}
require("nvim-tree").setup({
    hijack_netrw = false,
    open_on_setup = false,
    open_on_setup_file = false,
    view = {
        side = "right",
        mappings = mappings,
        number = ture,
        relativenumber = ture,
        signcolumn = "yes",
        preserve_window_proportions = true,
    },
    respect_buf_cwd = true,
    actions = {
        open_file = {
            resize_window = false,
        },
    },
})
