export SSH_AUTH_SOCK="/tmp/ssh-agent.${EUID}.socket"
[[ -S "${SSH_AUTH_SOCK}" ]] || ssh-agent -s -a "${SSH_AUTH_SOCK}" > /dev/null
ssh-add -l > /dev/null || find ~/.ssh -name 'id_*' -not -name '*.pub' -print0 | xargs -0 ssh-add
