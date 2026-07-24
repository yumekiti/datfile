eval "$(zoxide init bash --cmd cd)"

alias ls='eza --icons --group-directories-first'
alias l='eza --icons --group-directories-first -a'
alias cat='bat --paging=never --style=plain'
alias c='bat --paging=never --style=plain'
alias dif='difit'
clipbash() {
  pbpaste | /opt/homebrew/bin/bash
}

clipwrite() {
  if [ "$#" -ne 1 ]; then
    printf 'usage: clipwrite PATH\n' >&2
    return 2
  fi

  pbpaste > "$1"
}

vi() {
  if command -v difit >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    pkill -f 'difit --keep-alive' 2>/dev/null
    difit --keep-alive >/dev/null 2>&1 &
    disown $! 2>/dev/null
  fi

  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

