# PROMPT_SUBST permits parameter and command expansion inside prompt strings.
# https://zsh.sourceforge.io/Doc/Release/Options.html#Prompting
setopt PROMPT_SUBST

# vcs_info supplies repository, branch, and action fields before each prompt.
# add-zsh-hook installs lifecycle hooks without replacing other hook functions.
# https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Version-Control-Information
# https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Hook-Functions
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
autoload -Uz add-zsh-hook vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*:*' formats '%B%r%%b/%S' '%s:%b'
zstyle ':vcs_info:*:*' actionformats '%B%r%%b/%S' '%s:%b (%a)'
zstyle ':vcs_info:*:*' nvcsformats '%~' ''

# vcs_info does not inspect worktree changes by default. A single quiet diff adds
# an asterisk when tracked content differs from HEAD. Outside a repository Git
# returns a different status and nothing is printed.
# https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---quiet
refined_git_dirty() {
  command git diff --quiet --ignore-submodules HEAD &>/dev/null
  (( $? == 1 )) && print '*'
}

refined_repository_information() {
  print "%F{blue}${vcs_info_msg_0_%%/.} %F{8}${vcs_info_msg_1_}$(refined_git_dirty)%f"
}

# preexec records command start time. precmd reports elapsed whole seconds only
# when a command took longer than five seconds.
# https://zsh.sourceforge.io/Doc/Release/Functions.html#Hook-Functions
refined_command_elapsed() {
  local stopped_at elapsed
  stopped_at=$(date +%s)
  elapsed=$(( stopped_at - ${refined_command_started_at:-stopped_at} ))
  (( elapsed > 5 )) && print "${elapsed}s"
}

refined_preexec() {
  refined_command_started_at=$(date +%s)
}

refined_precmd() {
  setopt localoptions nopromptsubst
  vcs_info
  print -P "\n$(refined_repository_information) %F{yellow}$(refined_command_elapsed)%f"
  unset refined_command_started_at
}

add-zsh-hook preexec refined_preexec
add-zsh-hook precmd refined_precmd

# Show command success/failure and root/user privilege in the left prompt. Show
# user@host on the right only during SSH sessions.
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
PROMPT='%(?.%F{magenta}.%F{red})%(!.#.❯)%f '
RPROMPT='%F{8}${SSH_TTY:+%n@%m}%f'
