# History options preserve command timestamps, share history between shells,
# skip consecutive duplicates, and normalize excess whitespace.
# https://zsh.sourceforge.io/Doc/Release/Options.html#History
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS

# Permit comments while typing interactively.
# https://zsh.sourceforge.io/Doc/Release/Options.html#Interactive-Comments
setopt INTERACTIVE_COMMENTS

# Zsh history parameters control the on-disk file and in-memory/save limits.
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#index-HISTCHARS
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# Keep startup orchestration here and implementation in focused files.
# https://zsh.sourceforge.io/Doc/Release/Files.html#Files
source "$HOME/.config/zsh/paths.zsh"
for file in "$HOME/.config/zsh/aliases.zsh" \
  "$HOME/.config/zsh/functions.zsh" \
  "$HOME/.config/zsh/prompt.zsh" \
  "$HOME"/.config/zsh/lang/*.zsh(N); do
  source "$file"
done

# Initialize Zsh's native completion system.
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Initialization
# Initialize direnv project environments and fzf completion/key bindings.
# https://direnv.net/docs/hook.html
# https://junegunn.github.io/fzf/shell-integration/
autoload -Uz compinit && compinit
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v fzf >/dev/null && eval "$(fzf --zsh)"
