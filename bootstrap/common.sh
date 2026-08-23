#!/usr/bin/env bash

# Shared post-package setup for mutable Linux distributions. Distro entry
# points enable strict mode before sourcing this file.
# https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin

dotfiles_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
readonly dotfiles_directory
readonly nix_binary="/nix/var/nix/profiles/default/bin/nix"
readonly nix_installer_url="https://install.determinate.systems/nix"
readonly stow_packages=(shell nvim tmux git foot)

# Root execution would deploy links and Nix state into the wrong home.
require_target_user() {
  if [[ "${EUID}" -eq 0 ]]; then
    printf 'error: run as the target user, not root\n' >&2
    return 1
  fi
}

# os-release provides stable distribution identification. ID_LIKE admits
# derivatives such as EndeavourOS while still rejecting unrelated systems.
# https://www.freedesktop.org/software/systemd/man/latest/os-release.html
require_distribution() {
  local expected_distribution="$1"

  if [[ ! -r /etc/os-release ]]; then
    printf 'error: /etc/os-release is unavailable\n' >&2
    return 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "${expected_distribution}" &&
    " ${ID_LIKE:-} " != *" ${expected_distribution} "* ]]; then
    printf 'error: expected %s or a derivative, found %s\n' \
      "${expected_distribution}" "${ID:-unknown}" >&2
    return 1
  fi
}

# Determinate Nix supplies a multi-user Nix installation on non-NixOS hosts.
# The temporary installer is removed on success or failure.
# https://docs.determinate.systems/determinate-nix/
install_determinate_nix() {
  if [[ -x "${nix_binary}" ]]; then
    return
  fi

  (
    local installer
    installer="$(mktemp)"
    trap 'rm -f -- "${installer}"' EXIT
    curl --fail --location --proto '=https' --tlsv1.2 \
      "${nix_installer_url}" --output "${installer}"
    sh "${installer}" install --no-confirm
  )
}

# Stow links each named package tree into HOME and safely supports restowing.
# Accepting the executable path lets SteamOS use Stow from its new Nix profile
# before the next login updates PATH.
# https://www.gnu.org/software/stow/manual/stow.html
deploy_dotfiles() {
  local stow_binary="$1"

  "${stow_binary}" --dir "${dotfiles_directory}" --target "${HOME}" --restow \
    "${stow_packages[@]}"
}

# Docker is a root-owned system service. Group membership grants daemon access
# without sudo and therefore root-equivalent privileges.
# https://docs.docker.com/engine/install/linux-postinstall/
# /bin/zsh remains stable across package upgrades, unlike a Nix store path.
# https://man7.org/linux/man-pages/man1/chsh.1.html
configure_mutable_linux_system() {
  sudo systemctl enable --now docker.service
  sudo usermod --append --groups docker "${USER}"

  if [[ "$(getent passwd "${USER}" | cut --delimiter=: --fields=7)" != "/bin/zsh" ]]; then
    chsh --shell /bin/zsh
  fi

  deploy_dotfiles "$(command -v stow)"
  printf '\nBootstrap complete. Log out and back in for shell and group changes.\n'
}
