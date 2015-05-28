
function bc_help {

  local script_name=$1

  cat << HELP
Usage: $script_name [-hv] [-r CMD] [PACKAGE]

    -h          display this help and exit
    -v          verbose mode
    -r CMD      run the command CMD
       list         list all packages and versions
       setup        setup misc tools for the dev environment
    PACKAGE     specify a package to build

HELP

}
