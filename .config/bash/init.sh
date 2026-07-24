eval "$(zoxide init bash)"

alias ls='eza --icons --group-directories-first'
alias l='eza --icons --group-directories-first -a'
alias cat='bat --paging=never --style=plain'
vi() {
  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}
