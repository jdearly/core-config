#!/usr/bin/env bash
# Exit on failed commands, unset variables, or failed pipeline components.
# https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly script_directory
# shellcheck source=bootstrap/common.sh
source "${script_directory}/../bootstrap/common.sh"

# Fedora owns global programs and services. Development toolchains stay in
# project flakes. Names map Fedora packages to the shared tools documented in
# README.md.
# https://docs.fedoraproject.org/en-US/quick-docs/dnf/
readonly fedora_core_packages=(
  bat
  ctags
  curl
  direnv
  docker-compose-plugin
  fd-find
  firefox
  foot
  fzf
  git
  git-delta
  jq
  make
  moby-engine
  neovim
  ripgrep
  stow
  tmux
  wl-clipboard
  zsh
)

# Validate all preconditions before the first system mutation.
require_target_user
require_distribution fedora

# DNF converges installed package presence without forcing a system upgrade.
sudo dnf install --assumeyes "${fedora_core_packages[@]}"
install_nix linux
configure_mutable_linux_system
