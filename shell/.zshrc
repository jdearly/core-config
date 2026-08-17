setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS
setopt AUTO_CD INTERACTIVE_COMMENTS

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

source "$HOME/.config/zsh/paths.zsh"

for file in "$HOME/.config/zsh/aliases.zsh" \
  "$HOME/.config/zsh/functions.zsh" \
  "$HOME"/.config/zsh/lang/*.zsh(N); do
  source "$file"
done

FPATH="$HOME/.nix-profile/share/zsh/site-functions:$FPATH"
autoload -Uz compinit && compinit

command -v mise >/dev/null && eval "$(mise activate zsh)"
command -v fzf >/dev/null && eval "$(fzf --zsh)"
