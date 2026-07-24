eval "$(zoxide init bash)"

alias ls='eza --icons --group-directories-first'
alias l='eza --icons --group-directories-first -a'
unalias cat 2>/dev/null || true
unset -f cat 2>/dev/null || true
alias c='bat --paging=never --style=plain'
vi() {
  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

