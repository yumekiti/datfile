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
  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

