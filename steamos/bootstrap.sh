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

# The Steam Deck planner handles SteamOS persistence. Upstream Nix avoids
# Determinate Nixd, which cannot be installed on SteamOS's read-only root.
# The core-tools profile then puts user programs in the persistent Nix store.
# https://github.com/DeterminateSystems/nix-installer#compatibility
# https://github.com/DeterminateSystems/nix-installer#installing-upstream-nix
# https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-profile-install
install_nix steam-deck --prefer-upstream-nix
"${nix_binary}" profile install "path:${dotfiles_directory}#core-tools"

deploy_dotfiles "${HOME}/.nix-profile/bin/stow"
printf '\nSteamOS bootstrap complete. Start Zsh with ~/.nix-profile/bin/zsh.\n'
