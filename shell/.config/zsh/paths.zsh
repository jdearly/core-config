# Zsh's unique array removes duplicate PATH entries while preserving order.
# https://zsh.sourceforge.io/Doc/Release/Parameters.html#index-path
# ~/.local/bin is the conventional location for user-owned executables.
# https://www.freedesktop.org/software/systemd/man/latest/file-hierarchy.html
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  $path
)
export PATH

# Programs that honor EDITOR or VISUAL should launch the shared editor.
# TERMINAL and BROWSER are common, non-POSIX application preferences.
# https://pubs.opengroup.org/onlinepubs/9799919799/basedefs/V1_chap08.html
# https://man.archlinux.org/man/foot.1.en
# https://www.mozilla.org/firefox/
export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=foot
export BROWSER=firefox
