# Create exactly one directory tree and enter it only if creation succeeds.
# https://zsh.sourceforge.io/Doc/Release/Functions.html#Shell-Functions
# https://www.gnu.org/software/coreutils/manual/html_node/mkdir-invocation.html
mkcd() {
  if (( $# != 1 )); then
    print -u2 'usage: mkcd <directory>'
    return 2
  fi

  mkdir -p -- "$1" && cd -- "$1"
}
