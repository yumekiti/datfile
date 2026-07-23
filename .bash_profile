export BASH_SILENCE_DEPRECATION_WARNING=1
eval eval -- "$(/opt/homebrew/bin/starship init bash --print-full-init)"
eval "$(zoxide init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$HOME/.local/bin:$PATH"

alias ls='eza'
alias cat='bat'
