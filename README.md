# Dotfile Collection

This repo is originally a **vim/neovim** configuration project with plugins manually
managed with `git submodule`. But now, it has be expanded into a **dotfile collection**
with numerous configuration files across **multiple platforms**.


### Neovim

#### Overview

##### Supported languages

| Languages               | Completion | Syntax check |
| :--:                    | :--:       | :--:         |
| Markdown                | &radic;    | N/A          |
| C/C++                   | &radic;    | &radic;      |
| Python                  | &radic;    | &radic;      |
| Javascript / Typescript | &radic;    | &radic;      |

##### Other features of neovim:

- Git command integration
- Directory list (`<leader>e`)
- Ctag (`<leader>w`)
- Enhanced searching (`<leader><leader>f`)
- Snippets (`<C-l>`) and emmet (`<C-x>,`) support
- Global finder (`:CtrlSF`)


#### Quick Start

##### Installation

First, ensure **Neovim** is installed on your machine, if not, try *this guide*.

Link file `init.vim` to nvim's config directory:

##### For unix:
```bash
git clone 
mkdir -p ~/.config/nvim
ln ~/.config/nvim/init.vim vim/init.vim
```

##### For windows:
```powershell
New-Item -ItemType SymbolicLink -Path $HOME\AppData\Local\nvim\init.vim -Target .\vim\init.vim
````

Next, type `nvim` in shell to get in neovim, and type `:PlugInstall` to install
all plugins.

Finally, we use [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe) as completer
for languages such as c/c++, python, rust. YouCompleteMe is a powerful plugin which
supports lots of languages, but at the same time it is **hard** to configure. Here
I will just list configuration commands for python and c/c++ on ubuntu as an example. For more
support please refer to [YouCompleteMe's official guide](https://github.com/ycm-core/YouCompleteMe#installation).
```bash
sudo apt install build-essential cmake vim python3-dev
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --clangd-completer
```

##### Usages

| Keybinding | Operation | 
|:--:|:--|
| `<leader>gf` | Format|
| `<leader>gd` | Go to definition|
| `<leader>gt` | Get type|
| `<leader>gi` | Go to included head file|
| `<leader>gr` | Go to references|
| `<leader>gp` | Toggle preview |
| `<leader>sr` | Restart Ycm server |
| `<leader>sl` | Toggle errors |
| `<leader>sk` | Do syntastic check |
| `<leader>e` | Toggle directory list |
| `<leader>w` | Toggle tag bar |
| `<leader>mp` | Start markdown preview |
| `<leader>ms` | Stop markdown preview |
| `<leader>tl` | List all tags |
| `<leader>t[0-9]` | Switch to tag `#[0-9]` |
| `<leader>bl` | List all buffers |
| `<leader>b[0-9]` | Switch to buffer `#[0-9]` |
| `<leader>y` | Copy content to system clipboard |
| `<leader>p` | Paste content in system clipboard to vim |
| `<C-c>h` | Switch to previous tag |
| `<C-c>l` | Switch to next tag |
| `<C-x>,` | Expand snippets |


### Powershell Profile

```powershell
New-Item -ItemType SymbolicLink -Path $PROFILE -Target .\powershell\Microsoft.PowerShell_profile.ps1
```


### Vscode Settings And Keybindings on Windows

```powershell
New-Item -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\settings.json -Target .\vscode\settings.json
New-Item -ItemType SymbolicLink -Path $HOME\AppData\Roaming\Code\User\keybindings.json .\vscode\keybindings.json
```


### Windows Terminal

```powershell
New-Item -ItemType SymbolicLink -Path $HOME\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json -Target .\windows-terminal\settings.json
```


### Alacritty

For unix like systems:
```bash
mkdir -p $HOME/.config/alacritty/alacritty.yml
ln -s $(pwd)/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml
```

For bare windows:
```powershell
mkdir -Force $Env:APPDATA\alacritty
New-Item -Type SymbolicLink -Path $Env:APPDATA\alacritty\alacritty.yml -Value alacritty\alacritty.windows.yml
# Note: The path of WSL files starts with "\\wsl$\<distro_name>\"
# If this repo is under windows subsystem linux, to link file to windows system:
# New-Item -Type SymbolicLink -Path $Env:APPDATA\alacritty\alacritty.yml -Value \\wsl$\<distro_name>\<path_to_this_repo>\alacritty\alacritty.windows.yml
```


### TODO

- Complete the description of implemented features
- Marker plugins
- Try fcitx.vim
