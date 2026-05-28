set -gx LANG en_US.UTF-8
set -gx EDITOR vim
set -gx VISUAL nano
set -x NOCTALIA_VERSION (noctalia -v | awk '{ print $2 }')
set -x SH fish
fish_add_path $HOME/.local/bin
