# A Configured Vim/Neovim

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

**First**, backup your original vim configure file. If it is at default configure
path, `~/.vim` and `~/.vimrc`, this will help
```bash
mv ~/.vim ~/.vim.bkp
mv ~/.vimrc ~/.vimrc.bkp
```

*For neovim users*, there is one more step
```bash
mv ~/.config/nvim/init.vim ~/.config/nvim/init.vim.bkp
```

The **next step** is to download the repository to `~/.vim` and link the `.vimrc`
file to home path.

```bash
git clone https://github.com/suida/vim ~/.vim
ln -s ~/.vim/.vimrc ~/.vimrc
```

*For neovim users*, run an extra command
```bash
ln -s ~/.vim/init.vim ~/config/nvim/init.vim
```

Then, there are some initialization commands to config plugins. To enable all the
features, you'd better run each of these vim commands **in vim**:
```vim
:call mkdp#util#install()
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
