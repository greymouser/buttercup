
function bc_cli_process {

  local cmd="build"

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
              bc_help >&2
              exit 1
              ;;
      esac
  done
  shift "$((OPTIND-1))"

  case "$command" in
    help)
      bc_help $0
      exit
      ;;
    list)
      bc_packages_init
      bc_packages_list
      ;;
    setup)
      bc_packages_init
      bc_devenv_install
      ;;
    build)
      bc_packages_init
      package="$1"
      [[ ! -z "$2" ]] && package_version="$2"
      package_version=${package_version:=$(bc_package_select_max_version $package)}
      bc_stages_run $package $package_version
      ;;
      *) bc_error "unknown command specified"
  esac

}
