# dotfiles

Portable UNIX development environment. Nix installs pinned tools on personal machines. GNU Stow deploys the same plain configuration files on work machines.

## Fedora with Nix

```sh
git clone https://github.com/jdearly/core-config ~/dotfiles
cd ~/dotfiles
nix run github:nix-community/home-manager/release-26.05 -- \
  switch --flake .#josh@framework -b pre-home-manager
```

After the first activation:

```sh
home-manager switch --flake ~/dotfiles#josh@framework
```

## Work machine

```sh
git clone https://github.com/jdearly/core-config ~/dotfiles
cd ~/dotfiles
stow shell nvim tmux git
```

Language toolchains and their editor tooling belong in each project through mise. Add global tooling only when repeated use justifies it.
