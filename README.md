# A Configured Vim/Neovim

This project is starting to migrate to **Neovim** for better portability.

## Features

### Supported Languages

| Languages | Completion | Syntax check |
|:--:|:--:|:--:|
| Markdown | &radic; | N/A |
| C/C++ | &radic; | &radic; |
| Python | &radic; | &radic; |

### Other Features

- Git command integration
- Directory list (`<leader>w`)
- Ctag (`<leader>w`)
- Enhanced inline searching (`<leader><leader>f`)

## Quick Start

### Installation

First, ensure **Neovim** is installed on your machine, if not, try *this guide*.

Link file `init.vim` to nvim's config directory:
```bash
git clone 
mkdir -p ~/.config/nvim
ln ~/.config/nvim/init.vim vim/init.vim
```

Finally, we use [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe) as completer
for languages such as c/c++, python, rust. YouCompleteMe is a powerful plugin which
supports lots of languages, but at the same time it is **hard** to configure. Here
I will just list configuration commands for python and c/c++ as an example. For more
support please refer to [YouCompleteMe's official guide](https://github.com/ycm-core/YouCompleteMe#installation).
```bash
sudo apt install build-essential cmake vim python3-dev
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --clangd-completer
```

## Usages

### Language Supports

| Keybinding | Operation | 
|:--:|:--|
| `<leader><leader>ff<the-charactor-to-search>` | Enhanced search |
| `<leader>gf` | Format (supported by YcmCompleter)|
| `<leader>gd` | Go to definition (supported by YcmCompleter)|
| `<leader>gt` | Get type (supported by YcmCompleter)|
| `<leader>gi` | Go to included head file (supported by YcmCompleter)|
| `<leader>gr` | Go to references (supported by YcmCompleter)|
| `<leader>gp` | Toggle preview |
| `<leader>sr` | Restart Ycm server |
| `<leader>sl` | Toggle errors |
| `<leader>sk` | Do syntastic check |
| `<leader>y "*y` | Copy content to system clipboard |
| `<leader>p "*p` | Paste content in system clipboard to vim |



## TODO

- Complete the description of implemented features
- Marker plugins
- Try fcitx.vim


## Windows Neovim

New-Item -ItemType SymbolicLink -Path $HOME\AppData\Local\nvim\init.vim -Target .\vim\init.vim


## Powershell Profile

New-Item -ItemType SymbolicLink -Path $PROFILE -Target .\powershell\Microsoft.PowerShell_profile.ps1


## Vscode Settings And Keybindings on Windows

New-Item -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\settings.json -Target .\vscode\settings.json
New-Item -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\keybindings.json .\vscode\keybindings.json


## Windows Terminal

New-Item -ItemType SymbolicLink -Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json -Target .\windows-terminal\settings.json
