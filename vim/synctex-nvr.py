import time
import subprocess
from sys import argv
from pathlib import Path

# wsl -u <username> -d <distro_name> -e <abspath_to_python> <abspath_to_this_file> --remote +"%l" "%f"

SERVER_FILE = Path.home() / 'tmp/curnvimserver.txt'

class ForwardArgs:
    def __init__(self) -> None:
        self.forward_args = [
            # Path to nvr executable (in neovim-remote package)
            str(Path.home() / '.pyenv/versions/nvim/bin/nvr'),
            '--servername',
            '<placeholder>',
            '-c',
            '"normal! zzzv"',
            '<placeholder>',
            '<placeholder>',
        ]

    def set_server(self, s: str) -> 'ForwardArgs':
        self.forward_args[-5] = s.strip()
        return self

    def set_line(self, l: str) -> 'ForwardArgs':
        self.forward_args[-2] = l.strip()
        return self

    def set_file(self, f: str) -> 'ForwardArgs':
        self.forward_args[-1] = f.strip()
        return self

    def to_commands(self) -> list:
        return self.forward_args

def win_to_unix(p: str) -> str:
    if not p.lower().startswith('c:\\'):
        return p
    path = Path.home() / '/'.join( p.split('\\')[3:])
    return str(path)

def main():
    assert len(argv) == 4 or len(argv) == 3, 'Invalid options'

    forward_args = ForwardArgs()
    with open(SERVER_FILE) as f:
        forward_args    \
            .set_server(f.readline())   \
            .set_line(argv[-2])  \
            .set_file(win_to_unix(argv[-1]))

    # print(forward_args.to_commands())
    # time.sleep(5)
    subprocess.run(forward_args.to_commands())
        

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        print(e)
        time.sleep(5)
