# nvim-agent (profile)

A thin standalone Neovim profile that launches the agent cockpit:
`NVIM_APPNAME=nvim-agent nvim`.

It only sets options, bootstraps lazy.nvim + snacks.nvim, and loads the
`agent-cockpit.nvim` plugin from the sibling directory. All functionality
lives in the plugin — see `../agent-cockpit.nvim/README.md`.
