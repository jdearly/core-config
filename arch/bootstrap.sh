#!/usr/bin/env bash
# Exit on failed commands, unset variables, or failed pipeline components.
# https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly script_directory
# shellcheck source=bootstrap/common.sh
source "${script_directory}/../bootstrap/common.sh"

# Arch owns global programs and services. Development toolchains stay in
# project flakes. Names map Arch packages to the shared tools documented in
# README.md.
# https://wiki.archlinux.org/title/Pacman
readonly arch_core_packages=(
  bat
  curl
  direnv
  docker
  docker-compose
  fd
  firefox
  foot
  fzf
  git
  git-delta
  jq
  make
  neovim
  ripgrep
  stow
  tmux
  universal-ctags
  wl-clipboard
  zsh
)

# Validate all preconditions before the first system mutation.
require_target_user
require_distribution arch
if [[ "${ID}" == "steamos" ]]; then
  printf 'error: SteamOS is immutable; use steamos/bootstrap.sh\n' >&2
  exit 1
fi

# Arch does not support partial upgrades, so refresh and upgrade atomically
# while ensuring every shared package is present.
# https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported
sudo pacman --sync --refresh --sysupgrade --needed --noconfirm \
  "${arch_core_packages[@]}"
install_nix linux
configure_mutable_linux_system
