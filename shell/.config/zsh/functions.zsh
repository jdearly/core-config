mkcd() {
  if (( $# != 1 )); then
    print -u2 'usage: mkcd <directory>'
    return 2
  fi

  mkdir -p -- "$1" && cd -- "$1"
}
