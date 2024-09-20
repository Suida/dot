local wezterm = require 'wezterm'

function get_os_type()
  return package.config:sub(1, 1) == '/' and 'unix' or 'win32'
end

function TableConcat(t1, t2)
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'rose-pine-moon'
  else
    return 'rose-pine-dawn'
  end
end

wezterm.on('update-right-status', function(window, pane)
  local overrides = window:get_config_overrides() or {}
  local color = scheme_for_appearance(get_appearance())
  if overrides.color_scheme ~= color then
    overrides.color_scheme = color
    window:set_config_overrides(overrides)
  end
end)

local act = wezterm.action

-- Initial Key Bindings
local key_bindings = { -- {{{
  {
    key = '[',
    mods = 'LEADER',
    action = act.ActivateCopyMode,
  },
  {
    key = 'c',
    mods = 'ALT',
    action = act.CopyTo 'ClipboardAndPrimarySelection',
  },
  {
    key = 'v',
    mods = 'ALT',
    action = act.PasteFrom 'Clipboard',
  },
  {
    key = 'Space',
    mods = 'CTRL',
    action = act.SendKey { key = 'Escape', },
  },
} -- }}}

-- Key Bindings Pane Operations
local get_pane_key_bindings = function() -- {{{
  local ret = {
    {
      key = '|',
      mods = 'LEADER|SHIFT',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    },
    {
      key = '-',
      mods = 'LEADER',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
    },
    {
      key = 'x',
      mods = 'LEADER',
      action = act.CloseCurrentPane { confirm = true },
    },
    {
      key = 'h',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Left',
    },
    {
      key = 'l',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Right',
    },
    {
      key = 'k',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Up',
    },
    {
      key = 'j',
      mods = 'LEADER',
      action = act.ActivatePaneDirection 'Down',
    },
    {
      key = '1',
      mods = 'LEADER',
      action = act.ActivateTab(0),
    },
  }

  return ret
end
key_bindings = TableConcat(key_bindings, get_pane_key_bindings()) -- }}}

-- Key Bindings Tab  Operations
local get_tab_key_bindings = function() -- {{{
  local ret = {
    {
      key = 'c',
      mods = 'LEADER',
      action = act.SpawnCommandInNewTab {}
    },
    {
      key = 'h',
      mods = 'LEADER|CTRL',
      action = act.ActivateTabRelative(-1)
    },
    {
      key = 'l',
      mods = 'LEADER|CTRL',
      action = act.ActivateTabRelative(1)
    },
    {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateTabRelative(-1)
    },
    {
      key = 'n',
      mods = 'LEADER',
      action = act.ActivateTabRelative(1)
    },
  }
  for i = 1, 8 do
    table.insert(ret, {
      key = tostring(i),
      mods = 'LEADER',
      action = act.ActivateTab(i - 1),
    })
  end
  return ret
end
key_bindings = TableConcat(key_bindings, get_tab_key_bindings()) -- }}}

-- Key Bindings Window Operations
local get_win_key_bindings = function() -- {{{
  local ret = {
    {
      key = 'C',
      mods = 'LEADER|SHIFT',
      action = act.SpawnCommandInNewWindow {}
    },
    {
      key = 'P',
      mods = 'LEADER',
      action = act.ActivateWindowRelative(-1)
    },
    {
      key = 'N',
      mods = 'LEADER',
      action = act.ActivateWindowRelative(1)
    },
  }
  return ret
end
key_bindings = TableConcat(key_bindings, get_win_key_bindings()) -- }}}

local default_prog
if get_os_type() == 'win32' then
  default_prog = { 'pwsh' }
else
  default_prog = { 'zsh' }
end

return {
  font = wezterm.font 'CaskaydiaCove Nerd Font',
  font_size = 10.0,
  color_scheme = scheme_for_appearance(get_appearance()),
  default_prog = default_prog,

  cursor_blink_ease_in = 'Constant',
  cursor_blink_ease_out = 'Constant',

  use_fancy_tab_bar = false,
  tab_bar_at_bottom = true,

  window_padding = {
    left = 1,
    right = 1,
    top = 1,
    bottom = 0.5,
  },

  -- Mux{{{
  ssh_domains = {
    {
      -- This name identifies the domain
      name = 'ssh',
      -- The hostname or address to connect to. Will be used to match settings
      -- from your ssh config file
      remote_address = 'localhost',
      -- The username to use on the remote host
      username = 'wez',
    },
  },
  tls_servers = {
    {
      -- The host:port combination on which the server will listen
      -- for connections
      bind_address = 'localhost:29203',
    },
  },

  tls_clients = {
    {
      -- A handy alias for this session; you will use `wezterm connect server.name`
      -- to connect to it.
      name = 'main-server',
      -- The host:port for the remote host
      remote_address = 'localhost:29203',
      -- The value can be "user@host:port"; it accepts the same syntax as the
      -- `wezterm ssh` subcommand.
      bootstrap_via_ssh = 'hugh@localhost:29203',
    },
  }, -- }}}

  -- timeout_milliseconds defaults to 3000 and can be omitted
  leader = { key = 's', mods = 'CTRL', timeout_milliseconds = 3000 },
  keys = key_bindings,
  harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
  status_update_interval = 2000,
}
