#!/usr/bin/env bash
# SteamOS replaces its immutable system image during updates, so this script
# never disables read-only mode or installs persistent tools with pacman.
# https://help.steampowered.com/en/faqs/view/671A-4453-E8D2-323C
set -euo pipefail

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly script_directory
# shellcheck source=bootstrap/common.sh
source "${script_directory}/../bootstrap/common.sh"

require_target_user
require_distribution steamos

if ! command -v curl >/dev/null; then
  printf 'error: SteamOS must provide curl to bootstrap Nix\n' >&2
  exit 1
fi

# Determinate's installer has a supported Steam Deck planner. The core-tools
# flake package puts user programs in the persistent Nix store without mutating
# the SteamOS image.
# https://github.com/DeterminateSystems/nix-installer#compatibility
# https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-profile-install
install_determinate_nix
"${nix_binary}" profile install "path:${dotfiles_directory}#core-tools"

deploy_dotfiles "${HOME}/.nix-profile/bin/stow"
printf '\nSteamOS bootstrap complete. Start Zsh with ~/.nix-profile/bin/zsh.\n'
