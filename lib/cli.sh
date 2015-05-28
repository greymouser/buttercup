
function bc_cli_process {

  local cmd="build"
  local package="all"

  OPTIND=1
  while getopts "hvr:" opt; do
      case "$opt" in
          h)
              command="help"
              ;;
          v)  set -x
              ;;
          r)  command=$OPTARG
              ;;
          '?')
              fp_help >&2
              exit 1
              ;;
      esac
  done
  shift "$((OPTIND-1))"

  [[ ! -z "$1" ]] && package="$1"

  case "$command" in
    help)
      bc_help
      exit
      ;;
    list)
      bc_packages_init
      bc_packages_list
      ;;
    setup)
      bc_devenv_install
      ;;
      *) bc_error "unknown command specified"
  esac

}
