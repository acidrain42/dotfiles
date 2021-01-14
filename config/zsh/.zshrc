# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Profiling {{{

# https://kev.inburke.com/kevin/profiling-zsh-startup-time/
if [[ "${ZSH_PROFILE_STARTUP:-false}" == true ]]; then
    # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
    PS4=$'%D{%M.%S%.} %N:%i> '
    exec 3>&2 2>/tmp/startlog.$$
    setopt xtrace prompt_subst
fi

# }}}

# Modules Initializing {{{

fpath=("$HOME/.local/share/zsh/compl" $fpath)

autoload -U compinit promptinit
autoload -Uz vcs_info

compinit -i
promptinit

[[ -e $HOME/.tmux.zsh ]] && source $HOME/.tmux.zsh

# }}}

# Options {{{

setopt prompt_subst      # Enable parameter expansion for prompts
setopt correct           # Enable autocorrect
setopt auto_pushd        # Make cd push the old directory onto the directory stack
setopt pushd_ignore_dups # Ignore duplicates when pushing directory on the stack
setopt extendedglob      # Treat the `#', `~' and `^' characters as part of patterns for filename generation, etc.

# }}}

# Helper functions {{{

installed() {
    type "$1" &> /dev/null
    return $?
}

contains() {
    string="$1"
    substring="$2"
    if test "${string#*$substring}" != "$string"
    then
        return 0    # $substring is in $string
    else
        return 1    # $substring is not in $string
    fi
}

# }}}

# Key Bindings {{{

# Use VI mode
bindkey -v

# Reduce ESC delay to 0.1s
export KEYTIMEOUT=1

# bind special keys according to readline configuration
[ -f /etc/inputrc ] && eval "$(sed -n 's/^/bindkey /; s/: / /p' /etc/inputrc)" > /dev/null

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^W" backward-kill-word
bindkey "^R" history-incremental-search-backward
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey '^[[3~' delete-char

# Make backspace and ^h work after returning from normal mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# }}}

# ZStyle options {{{

# Add completion for cd ..
zstyle ':completion:*' special-dirs true
# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Version Control System
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' check-for-changes true

# }}}

# Source extra files {{{

ZSH_EXTRA_FILES=(
    "${ZDOTDIR}/aliases"
    "${ZDOTDIR}/functions"
    "${ZDOTDIR}/local"
    "/usr/local/bin/virtualenvwrapper_lazy.sh"
    "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    "/usr/share/doc/pkgfile/command-not-found.zsh"
)

for f in ${ZSH_EXTRA_FILES[@]}; do
    [[ -f "$f" ]] && . "$f"
done

# }}}

# Plugins {{{

for f in "${HOME}/.local/share/zsh/plugins"/*; do
    . "$f"
done

# }}}

# Misc configs and env vars {{{

[[ -f ~/.profile ]] && source ~/.profile

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if installed gdircolors; then
    [ -r ~/.dircolors ] && eval "$(gdircolors -b ~/.dircolors)" || eval "$(gdircolors -b)"
fi

# Enable core dumps
ulimit -c unlimited

# Setup default apps
if installed nvim; then
    export EDITOR="nvim"
else
    export EDITOR="vim"
fi

# Default cflags
export CFLAGS="-O2 -march=native -fstack-protector-strong"

# Remove / from WORDCHARS, ie. make / a word delimiter
export WORDCHARS=${WORDCHARS/\//}

# Use Python3 for virtualenvwrapper
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3

# Don't prepend virtual env name to PS1
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Android
ANDROID_SDK_ROOT="$HOME/Android/Sdk"
if [ -d "$ANDROID_SDK_ROOT" ]; then
    export ANDROID_SDK_ROOT
    export PATH="$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools:$PATH"
fi

# Python
[[ -f "$HOME/.pythonrc" ]] && export PYTHONSTARTUP="$HOME/.pythonrc"

# }}}

# Cleanup {{{

unset -f installed

if [[ "${ZSH_PROFILE_STARTUP:-false}" == true ]]; then
    unsetopt xtrace
    exec 2>&3 3>&-
fi

# }}}

# vi: foldmethod=marker
