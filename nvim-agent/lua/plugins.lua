-- Plugin specs for lazy.nvim. snacks.nvim is the only dependency.
-- resolve(): this profile is usually loaded through the %LOCALAPPDATA%\nvim-agent
-- junction; the realpath points into the actual repo, whose root also holds
-- the agent-cockpit.nvim plugin dir.
local src = vim.fn.resolve(debug.getinfo(1, 'S').source:sub(2)):gsub('\\', '/')
local repo = vim.fn.fnamemodify(src, ':h:h:h') -- <repo>/nvim-agent/lua/plugins.lua -> <repo>
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      picker = { enabled = true },
      explorer = {
        enabled = true,
        -- Open selected files in the cockpit's review area, not over an agent.
        actions = {
          confirm = function(p, item)
            p:close()
            if item and item.file then
              require('agent-cockpit.zones').edit(item.file)
            end
          end,
        },
        -- Collapsible, left by default; move to the right with:
        -- layout = { layout = { position = 'right' } },
      },
      notify = { enabled = true },
      input = { enabled = true },
      terminal = { enabled = true },
    },
  },
  {
    dir = repo .. '/agent-cockpit.nvim',
    name = 'agent-cockpit',
    lazy = false,
    dependencies = { 'folke/snacks.nvim' },
    config = function() require('agent-cockpit').setup({}) end,
  },
}
