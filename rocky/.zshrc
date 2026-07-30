# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Completions — only full reinit once per day, cached otherwise
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Modern replacements
alias ls='eza -a --icons=auto'
alias ll='eza -la --icons'
alias cat='bat'
alias cd='z'

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide
source ~/.zsh_zoxide_init

export PATH="$HOME/.local/bin:$HOME/.bun/bin:$PATH"

# Powerlevel10k
source ~/.config/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Syntax highlighting — must be last
source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

eval "$(mise activate zsh)"
