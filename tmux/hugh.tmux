set -g status-style bg='#282c34'

# right side of status bar holds "[host name] (date time)"
set -g status-right-length 100
set -g status-right-style fg=black
set -g status-right-style bold
set -g status-right '#[fg=#f99157,bg=#2d2d2d] %H:%M |#[fg=#6699cc] %Y.%m.%d '

# make background window look like white tab
set-window-option -g window-status-style bg=default
set-window-option -g window-status-style fg=white
set-window-option -g window-status-style none
set-window-option -g window-status-format '#[fg=#6699cc] #I#[fg=#999999] #W #[282c34]'

# make foreground window look like bold yellow foreground tab
set-window-option -g window-status-current-style none
set-window-option -g window-status-current-format '#[fg=#f99157] #I#[fg=#cccccc] #W#[default]'

# message bar or "prompt"
set -g message-style bg="#2d2d2d"
set -g message-style fg="#e45649"

set -g pane-border-style bg=default
set -g pane-border-style fg="#bfceff"

