
function bc_pushd {
  pushd "$1" > /dev/null
}

function bc_popd {
  popd > /dev/null
}

function bc_array_contains {
  # element, array

  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

function bc_array_pretty_print {
  # array

  local arr=$1
  for key in ${!1[@]}; do
    echo $key
  done
}

function bc_error_report {
  echo "There was a problem with $1"
  exit 1
}

function bc_error {
    echo "$1"
    # [[ -z "$2" ]] && exit 1
    exit 1
}
