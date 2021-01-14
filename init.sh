#! /bin/bash -eu

info()         { printf "\\e[32m[INFO]\\e[0m    %s\\n" "$*" ; }
warning()      { printf "\\e[33m[WARNING]\\e[0m %s\\n" "$*" ; }
error()        { printf "\\e[31m[ERROR]\\e[0m   %s\\n" "$*" >&2 ; }
fatal()        { printf "\\e[35m[FATAL]\\e[0m   %s\\n" "$*" >&2 ; exit 1 ; }
prompt_no_nl() { printf "\\e[36m[PROMPT]\\e[0m  %s" "$*" >&2; read -r -n1 resp; echo "$resp" ; }

DOTFILES=(
    'Xmodmap'
    'dircolors'
    'gitconfig'
    'ideavimrc'
    'profile'
    'templates'
    'tmux.zsh'
    'zshenv'
)

DIRS=(
    '.config'
    '.fonts'
    '.local/share'
    'usr/bin'
    'usr/lib'
)

APPS=(
    'bat'
    'cargo'
    'colordiff'
    'exa'
    'fd'
    'fzf'
    'handlr'
    'lrzip'
    'node'
    'rg'
    'sd'
    'terminal-notifier'
    'tmux'
    'yarn'
)

function get_real_path() {
    if type greadlink &> /dev/null; then
        greadlink -f "$0"
    else
        perl -e 'use Cwd "abs_path"; print abs_path(shift)' "$1"
    fi
}

DOTFILES_DIR="$(get_real_path "$(dirname "${BASH_SOURCE[0]}")")"

unattended=0

if [[ $# -ge 1 ]] && [[ "$1" == "-u" ]]; then
    unattended=1
fi

function installed() {
    type "$1" &> /dev/null
    return $?
}

function ask_yes_no {
    if [[ "${unattended}" != 1 ]]; then
        resp=$(prompt_no_nl "$1")

        [[ -z "$resp" ]] && resp="$2" || echo
    else
        resp="$2"
    fi

    if [[ "$resp" = "y" ]] || [[ "$resp" = "Y" ]]; then
        return 0
    else
        return 1
    fi
}

function hash() {
    md5 -r "$1" | cut -d ' ' -f 1
}

function create_link() {
    [[ -L "$1" ]] && rm "$1"
    [[ -e "$1" ]] && mv "$1" "${1}.bak"

    ln -s "$2" "$1"
}

function copy_file() {
    local dst="$1"
    local src="$2"

    [[ -L "$dst" ]] && rm "$dst"

    if [[ -e "$dst" ]]; then
        [[ "$(hash "$src")" == "$(hash "$dst")" ]] && return

        mv "$dst" "${dst}.bak"
    fi

    cp "$src" "$dst"
}

for dir in "${DIRS[@]}"; do
    [[ -d "$HOME/${dir}" ]] || mkdir -p "$HOME/${dir}"
done

for file in "${DOTFILES[@]}"; do
    create_link "$HOME/.${file}" "$DOTFILES_DIR/${file}"
done

for file in "${DOTFILES_DIR}"/config/*; do
    create_link "$HOME/.config/$(basename "$file")" "$file"
done

for file in "${DOTFILES_DIR}"/share/*; do
    create_link "$HOME/.local/share/$(basename "$file")" "$file"
done

if ask_yes_no "Install fonts [y/N]? " "n"; then
    for file in "${DOTFILES_DIR}"/fonts/*; do
        copy_file "$HOME/Library/Fonts/$(basename "$file")" "$file"
    done
fi

for file in "${DOTFILES_DIR}"/usr/bin/*; do
    create_link "$HOME/usr/bin/$(basename "$file")" "$file"
done

for file in "${DOTFILES_DIR}"/usr/lib/*; do
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
        info "Installing vim-plug"
        curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    if ask_yes_no "Install vim plugins [y/N]? " "n"; then
        # TERM workaround to avoid loading non existing color scheme
        TERM=xterm vim -S "$DOTFILES_DIR/vimplug.lock" +qall
    fi
fi

# Install modified terminfo
for file in "${DOTFILES_DIR}"/terminfo/*; do
    tic "${file}"
done

if installed tmux; then
    if [ ! -e "$HOME/.local/share/tmux/tpm" ]; then
        info "Installing tmux plugin manager"
        mkdir -p "$HOME/.local/share/tmux"
        git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/tpm
    else
        info "Updating tmux plugin manager"
        pushd "$HOME/.local/share/tmux/tpm" > /dev/null
        git pull
        popd > /dev/null
    fi
fi

for file in "${DOTFILES_DIR}"/terminfo/*; do
    tic -x "$file"
done

if [ "$TERM" = "xterm-256color" ] || [ "$TERM" = "screen-256color" ]; then
    # https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
    printf "Don't forget to set xterm-256color-italic in iTerm2 profile\\n"
fi

if installed cargo; then
    if ask_yes_no "Install cmus-notify [y/N]? " "n"; then
        pushd /tmp > /dev/null
        git clone https://github.com/mathieu-lemay/cmus-notify.git

        pushd cmus-notify > /dev/null
        cargo build --release
        mv target/release/cmus-notify "$HOME/usr/bin"
        popd > /dev/null

        rm -rf cmus-notify
        popd > /dev/null
    fi
fi

if installed pyenv; then
    pyenv_plugin_root="$(pyenv root)/plugins"

    if [ -e "${pyenv_plugin_root}/xxenv-latest" ]; then
        info "Updating pyenv-latest plugin"
        pushd "${pyenv_plugin_root}/xxenv-latest" > /dev/null
        git pull
        popd > /dev/null
    else
        info "Installing pyenv-latest plugin"
        [[ -d "$pyenv_plugin_root" ]] || mkdir -p "$pyenv_plugin_root"
        git clone https://github.com/momo-lab/xxenv-latest.git "${pyenv_plugin_root}/xxenv-latest"
    fi
fi

installed crontab && crontab "$DOTFILES_DIR/crontab"

if installed bat; then
    info "Building bat cache"
    bat cache --build > /dev/null
fi

MISSING_APPS=""
for app in "${APPS[@]}"; do
    installed "$app" || MISSING_APPS="${MISSING_APPS}${app} "
done

[[ -z "$MISSING_APPS" ]] || info "Don't forget to install the following: ${MISSING_APPS}"
