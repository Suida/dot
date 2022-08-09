#! /bin/env python
from pathlib import Path
from subprocess import getstatusoutput


HOME = Path.home()
TMUX_CONF_PATH = HOME / '.tmux.conf'
TMUX_PROFILE_PATH = HOME / '.tmux' / 'hugh.tmux'

FILE_PATH = Path(__file__).parent
SRC_TMUX_CONF_PATH = FILE_PATH / 'tmux.conf'
SRC_TMUX_PROFILE_PATH = FILE_PATH / 'hugh.tmux'


FILES_TO_LINK = [
    [TMUX_CONF_PATH, SRC_TMUX_CONF_PATH],
    [TMUX_PROFILE_PATH, SRC_TMUX_PROFILE_PATH],
]


def is_git_available():
    (ecode, _) = getstatusoutput('which git')
    return ecode == 0


def install_tpm():
    (ecode, info) = getstatusoutput('git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm')
    if ecode != 0:
        raise OSError(info)


def link_conf_files():
    for (dst, src) in FILES_TO_LINK:
        if not src.exists():
            raise OSError(f'${str(src)} does not exist.')
        dst.symlink_to(src)


def main():
    if not is_git_available():
        raise OSError('Git not installed.')
    install_tpm()
    link_conf_files()


if __name__ == '__main__':
    main()
