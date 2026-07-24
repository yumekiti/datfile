eval "$(zoxide init bash)"

alias ls='eza --icons --group-directories-first'
alias l='eza --icons --group-directories-first -a'
unalias cat 2>/dev/null || true
cat() {
  if [ -t 0 ] && [ -t 1 ] && [ "$#" -gt 0 ]; then
    bat --paging=never --style=plain "$@"
  else
    command cat "$@"
  fi
}
vi() {
  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

