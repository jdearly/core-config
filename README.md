# dotfiles

Portable UNIX development environment based on `UNIX as an IDE`. GNU Stow
deploys the same plain configuration files everywhere. Fedora and Arch use
small distro-specific bootstrap scripts. NixOS owns its system declaratively.
Project flakes own development dependencies.

## Shared tools

Every global tool supports the cross-project workflow. Remove it when that
statement stops being true.

| Tool | Why global | Reference |
|---|---|---|
| Zsh | One interactive shell and shared startup language | [Zsh documentation](https://zsh.sourceforge.io/Doc/Release/) |
| direnv | Enter and leave project flake environments automatically | [direnv](https://direnv.net/) |
| Git | Source history and collaboration | [Git reference](https://git-scm.com/docs) |
| delta | Readable Git paging and interactive staging | [delta](https://dandavison.github.io/delta/) |
| Neovim | Shared editor and quickfix workflow | [Neovim documentation](https://neovim.io/doc/) |
| Foot | One Wayland-native terminal emulator | [Foot documentation](https://codeberg.org/dnkl/foot) |
| Firefox | One browser across desktop hosts | [Firefox](https://www.mozilla.org/firefox/) |
| tmux | Persistent local and remote terminal sessions | [tmux manual](https://man.openbsd.org/tmux) |
| Universal Ctags | Optional native symbol navigation across languages | [Universal Ctags](https://docs.ctags.io/) |
| make | One repository command contract independent of language | [GNU Make manual](https://www.gnu.org/software/make/manual/) |
| ripgrep | Source-tree search consumed by Neovim and fzf | [ripgrep guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md) |
| fd | File discovery consumed by fzf | [fd](https://github.com/sharkdp/fd) |
| fzf | Interactive file, buffer, history, and search selection | [fzf](https://junegunn.github.io/fzf/) |
| jq | Structural selection for JSON-producing UNIX tools | [jq manual](https://jqlang.org/manual/) |
| bat | Readable previews used by fzf | [bat](https://github.com/sharkdp/bat) |
| Stow | Transparent deployment of plain dotfiles | [GNU Stow manual](https://www.gnu.org/software/stow/manual/stow.html) |
| Docker and Compose | Reproduce service dependencies on mutable hosts | [Docker documentation](https://docs.docker.com/) |
| curl | Bootstrap Nix and inspect HTTP endpoints | [curl documentation](https://curl.se/docs/) |

Berkeley Mono must be installed separately under its own license. Foot falls
back through fontconfig if it is unavailable, but the intended appearance
requires that font.

Home Manager, mise, global language toolchains, language servers, analyzers,
and debuggers are intentionally absent. Project flakes own project-specific
dependencies. Stow keeps home configuration portable and directly inspectable.

`flake.lock` and `nvim-pack-lock.json` are generated lock files. They pin inputs
rather than express policy and should be reviewed as dependency revisions:
[Nix flake locking](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake-lock) and
[`vim.pack` locking](https://neovim.io/doc/user/pack.html#vim.pack).

## Fedora

Install Fedora with the `josh` user, then run:

```sh
git clone https://github.com/jdearly/core-config ~/dotfiles
~/dotfiles/fedora/bootstrap.sh
```

## Arch and mutable Arch-based distributions

Install the distribution with the `josh` user and working `sudo` access, then
run:

```sh
git clone https://github.com/jdearly/core-config ~/dotfiles
~/dotfiles/arch/bootstrap.sh
```

The Fedora and Arch scripts install the shared system tools, Docker,
Determinate Nix, and Stow-managed configuration. They are safe to rerun. Log
out and back in afterward for the Zsh login shell and Docker group membership.

## SteamOS

SteamOS is Arch-based but immutable. Pacman-installed additions do not reliably
survive OS image updates, so it has a separate bootstrap that leaves the system
image read-only and installs core development tools through Nix:

```sh
git clone https://github.com/jdearly/core-config ~/dotfiles
~/dotfiles/steamos/bootstrap.sh
~/.nix-profile/bin/zsh
```

Project flakes and direnv then behave like the other hosts. The SteamOS setup
does not configure a Docker daemon. Add a container strategy only when an
active project requires one.

References: [Steam Deck desktop mode](https://help.steampowered.com/en/faqs/view/671A-4453-E8D2-323C)
and [Determinate Nix compatibility](https://github.com/DeterminateSystems/nix-installer#compatibility).

## NixOS

Import the shared module from the root flake alongside the host's generated
hardware configuration and host-specific settings:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    core-config.url = "github:jdearly/core-config";
    core-config.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {nixpkgs, core-config, ...}: {
    nixosConfigurations.my-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        core-config.nixosModules.default
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
```

After rebuilding, deploy the shared configuration:

```sh
git clone https://github.com/jdearly/core-config ~/dotfiles
stow --dir ~/dotfiles --target ~ --restow shell nvim tmux git foot
```

Host configuration remains in the consuming NixOS flake. This repository's
NixOS module owns only the shared user, programs, and services.

## Other systems and work machines

Install the shared tools using the system package manager, then deploy the same
dotfiles:

```sh
git clone https://github.com/jdearly/core-config ~/dotfiles
stow --dir ~/dotfiles --target ~ --restow shell nvim tmux git foot
```

## Project environments

Each project declares its language toolchain and development dependencies in a
pinned `flake.nix` and contains:

```sh
# .envrc
use flake
```

Run `direnv allow` once in the project. The shared Zsh configuration activates
and deactivates the flake environment when entering and leaving the directory.
Language servers, formatters, analyzers, debuggers, and profilers belong in the
project flake rather than the global system setup.

## Tags

Neovim's default `./tags;,tags` setting searches for `tags` beside the current
file and upward to the repository root. A project that benefits from symbol
navigation should expose this conventional target:

```make
.PHONY: tags
tags:
\tctags -R .
```

`Ctrl-]`, `g]`, `:tselect`, `:tnext`, and `:tprev` then use the generated index
without plugins. The global Git excludes file prevents generated `tags` files
from being committed. Projects with generated or vendored trees should add
project-specific Ctags exclusions.

References: [Neovim tag search](https://neovim.io/doc/user/tagsrch.html) and
[Universal Ctags recursion](https://docs.ctags.io/en/latest/man/ctags.1.html).
