typeset -U path PATH
path=(
  "$HOME/dotfiles/bin"
  "$HOME/.local/bin"
  "$HOME/.nix-profile/bin"
  $path
)
export PATH
export EDITOR=nvim
export VISUAL=nvim
