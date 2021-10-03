# For gruvbox dark
# set -g status-style bg=#282828
# For onehalflight:
set -g status-style bg=#eaeaea

# right side of status bar holds "[host name] (date time)"
set -g status-right-length 100
set -g status-right-style fg=black
set -g status-right-style bold
set -g status-right '#[fg=#f99157] %H:%M |#[fg=#6699cc] %Y.%m.%d '

# make background window look like white tab
set-window-option -g window-status-style none
set-window-option -g window-status-format '#[fg=#6699cc] #I#[fg=#888888] #W#[282c34]'

# make foreground window look like bold yellow foreground tab
set-window-option -g window-status-current-style none
set-window-option -g window-status-current-format '#[fg=#f99157] #I#[fg=#777777] #W#[282c34]'

# message bar or "prompt"
set -g message-style bg="#eaeaea"
set -g message-style fg="#e45649"

set -g pane-border-style bg='#282c34'
set -g pane-border-style fg="#bfceff"
