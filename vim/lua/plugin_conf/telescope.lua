local telescope_status_ok, telescope = pcall(require, 'telescope')
if not telescope_status_ok then
  return
end

telescope.load_extension('media_files')
telescope.load_extension('bibtex')

telescope.setup {
  extensions = {
    media_files = {
      filetypes = { 'png', 'jpg', 'mp4', 'webm', 'pdf' },
      find_cmd = 'rg',
    }
  },
  bibtex = {
    context = true,
    context_fallback = true,
  },
}
