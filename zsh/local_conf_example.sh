# Pipx & pipenv
export PATH="$PATH:/home/hugh/.local/bin"
autoload -U bashcompinit
bashcompinit
if [[ -e $PYENV_ROOT ]]
then
    eval "$(PATH=$PYENV_ROOT/versions/$(pyenv global)/bin:$PATH register-python-argcomplete pipx)"
else
    eval "$(register-python-argcomplete pipx)"
fi
eval "$(pipenv --completion)"
export PIPENV_VERBOSITY=-1

# Ninja completion
fpath=(/home/hugh/workspace/ninja-1.10.2/misc/zsh-completion $fpath)

# LLVM & Clangd
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export CPPFLAGS="-I/usr/local/opt/llvm/include"

# Vcpkg & cmake
export VCPKG_CMAKE_SCRIPT_PATH=$HOME/workspace/github/vcpkg/scripts/buildsystems/vcpkg.cmake

# Vivado
export PATH=/tools/Xilinx/Vivado/2022.1/bin:$PATH
