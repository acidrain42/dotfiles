#! /bin/bash -eu

fatal()   { printf "\\e[35m[FATAL]\\e[39m   %s\\n" "$*" 1>&2 ; exit 1 ; }

DOTFILES=(
    'SciTEUser.properties'
    'Xmodmap'
    'conkyrc'
    'dircolors'
    'gitconfig'
    'ideavimrc'
    'profile'
    'templates'
    'tmux.conf'
    'tmux.zsh'
    'zsh_aliases'
    'zsh_functions'
    'zshrc'
)

APPS=(
    'colordiff'
    'fd'
    'fzf'
    'rg'
    'terminal-notifier'
    'tmux'
)

function get_real_path() {
    if type greadlink &> /dev/null; then
        greadlink -f "$0"
    else
        perl -e 'use Cwd "abs_path"; print abs_path(shift)' "$1"
    fi
}

function installed() {
    type "$1" &> /dev/null
    return $?
}

function create_link() {
    [[ -L "$1" ]] && rm "$1"
    [[ -e "$1" ]] && mv "$1" "${1}.bak"

    ln -s "$2" "$1"
}

DOTFILES_DIR="$(dirname "$(get_real_path "${BASH_SOURCE[0]}")")"

[[ -d "$HOME/.config" ]] || mkdir "$HOME/.config"
[[ -d "$HOME/usr/bin" ]] || mkdir -p "$HOME/usr/bin"
[[ -d "$HOME/usr/lib" ]] || mkdir -p "$HOME/usr/lib"

for file in "${DOTFILES[@]}"; do
    create_link "$HOME/.${file}" "$DOTFILES_DIR/${file}"
done

for file in $DOTFILES_DIR/config/*; do
    create_link "$HOME/.config/$(basename "$file")" "$file"
done

for file in $DOTFILES_DIR/usr/bin/*; do
    create_link "$HOME/usr/bin/$(basename "$file")" "$file"
done

for file in $DOTFILES_DIR/usr/lib/*; do
    create_link "$HOME/usr/lib/$(basename "$file")" "$file"
done

if find "$HOME/usr" -xtype l &> /dev/null; then
    find "$HOME/usr" -xtype l -print0 | xargs -0 rm
fi

[[ -e "$DOTFILES_DIR/zsh.$(hostname)" ]] && ln -sf "$DOTFILES_DIR/zsh.$(hostname)" "$HOME/.zsh.local"

[[ -L "$HOME/.vim" ]] && rm "$HOME/.vim"
ln -s "$HOME/.config/nvim" "$HOME/.vim"

[[ -L "$HOME/.vimrc" ]] && rm "$HOME/.vimrc"
ln -s "$HOME/.config/nvim/init.vim" "$HOME/.vimrc"

if installed vim; then
    if [ ! -e "$HOME/.config/nvim/autoload/plug.vim" ]; then
        curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        # TERM workaround to avoid loading non existing color scheme
        TERM=xterm vim +PlugInstall +qall
    fi
fi

installed crontab && crontab "$DOTFILES_DIR/crontab"

MISSING_APPS=""
for app in "${APPS[@]}"; do
    installed "$app" || MISSING_APPS="${MISSING_APPS}${app} "
done

[[ -z "$MISSING_APPS" ]] || printf "Don't forget to install the following:\\n  %s\\n" "$MISSING_APPS"
