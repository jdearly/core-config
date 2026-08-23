setopt PROMPT_SUBST

autoload -Uz add-zsh-hook vcs_info
zstyle ':vcs_info:*' enable hg bzr git
zstyle ':vcs_info:*:*' unstagedstr '!'
zstyle ':vcs_info:*:*' stagedstr '+'
zstyle ':vcs_info:*:*' formats '%B%r%%b/%S' '%s:%b' '%%u%c'
zstyle ':vcs_info:*:*' actionformats '%B%r%%b/%S' '%s:%b' '%u%c (%a)'
zstyle ':vcs_info:*:*' nvcsformats '%~' '' ''

refined_git_dirty() {
  command git rev-parse --is-inside-work-tree &>/dev/null || return
  command git diff --quiet --ignore-submodules HEAD &>/dev/null
  (( $? == 1 )) && print '*'
}

refined_repository_information() {
  print "%F{blue}${vcs_info_msg_0_%%/.} %F{8}${vcs_info_msg_1_}$(refined_git_dirty) ${vcs_info_msg_2_}%f"
}

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

PROMPT='%(?.%F{magenta}.%F{red})%(!.#.❯)%f '
RPROMPT='%F{8}${SSH_TTY:+%n@%m}%f'
