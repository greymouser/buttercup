
BC_STAGES_ALL=(fetch unpack patch configure build install framework test pkgbuild productbuild)

. "${BC_LIB_DIR}/stages/fetch.sh"
. "${BC_LIB_DIR}/stages/unpack.sh"
. "${BC_LIB_DIR}/stages/patch.sh"
. "${BC_LIB_DIR}/stages/configure.sh"
. "${BC_LIB_DIR}/stages/build.sh"
. "${BC_LIB_DIR}/stages/install.sh"
. "${BC_LIB_DIR}/stages/framework.sh"
. "${BC_LIB_DIR}/stages/pkg.sh"

function bc_stages_env_base {
  local pn=$1
  local pv=$2

  BC_PN="$pn"
  BC_PV="$pv"

  BC_P="$BC_PN-$BC_PV"
  BC_P_DIR="$BC_PACKAGES_DIR/$BC_PN"
  BC_P_FILE="$BC_P_DIR/$BC_P.package"

  BC_S_DIR="$BC_SOURCE_DIR/$BC_PN"
  BC_W_DIR="$BC_WORK_DIR/$BC_P"
  BC_I_DIR="$BC_INSTALL_DIR/$BC_P"
  BC_D_DIR="$BC_DIST_DIR/$BC_PN"

  export BC_PN BC_PV
  export BC_P BC_P_DIR BC_P_FILE
  export BC_S_DIR BC_W_DIR BC_I_DIR BC_D_DIR
}

function bc_stages_env_base_clear {
  unset BC_PN BC_PV
  unset BC_P BC_P_DIR BC_P_FILE
  unset BC_S_DIR BC_W_DIR BC_I_DIR BC_D_DIR

  for stage in ${BC_STAGES_ALL[@]}; do
    unset bc_pkg_$stage
  done
}

function bc_stages_env_base_mkdirs {
  mkdir -p "${BC_S_DIR}"
  mkdir -p "${BC_W_DIR}"
  mkdir -p "${BC_I_DIR}"
  mkdir -p "${BC_D_DIR}"
}

function bc_stages_env_package {
  # sources & patches to fetch
  BC_PKG_PATCHES=${BC_PKG_PATCHES:=""}
  BC_PKG_SOURCES=${BC_PKG_SOURCES:=""}

  # configure, make, make install
  BC_PKG_SOURCE_DIR=${BC_PKG_SOURCE_DIR:=$BC_W_DIR/$BC_PKG_P}
  BC_PKG_BUILD_DIR=${BC_PKG_BUILD_DIR:=$BC_PKG_SOURCE_DIR}
  BC_PKG_CONFIGURE_SCRIPT=${BC_PKG_CONFIGURE_SCRIPT:=$BC_PKG_SOURCE_DIR/configure}

  # frameworks
  BC_PKG_FRAMEWORK_DIR="/Library/Frameworks/$BC_PKG_PN.framework"
  BC_PKG_FRAMEWORK_PREFIX="$BC_PKG_FRAMEWORK_DIR/Versions/$BC_PKG_FRAMEWORK_VERSION"

  export BC_PKG_SOURCE_DIR BC_PKG_BUILD_DIR BC_PKG_CONFIGURE_SCRIPT
  export BC_PKG_FRAMEWORK_DIR BC_PKG_FRAMEWORK_PREFIX
}

function bc_stages_env_package_clear {
  unset BC_PKG_FRAMEWORK_DIR BC_PKG_FRAMEWORK_PREFIX
  unset BC_PKG_SOURCE_DIR BC_PKG_BUILD_DIR BC_PKG_CONFIGURE_SCRIPT
}

function bc_stage_run {
  local stage=$1
  local stage_target="bc_pkg_$stage"
  local stage_done_file="$BC_W_DIR/$BC_P.$stage"

  if [[ "$(type -t $stage_target)" == "function" ]]; then

    if [[ ! -f "$stage_done_file" ]]; then
      $stage_target
      bc_local_run touch $stage_done_file
    fi
  elif [[ "skip" == "${!stage_target}" ]]; then

    return

  elif [[ "default" == "${!stage_target}" ]]; then

    if [[ ! -f "$stage_done_file" ]]; then
      bc_stages_${stage}_default
      bc_local_run touch $stage_done_file
    fi

  elif [[ "devtools" == "${!stage_target}" ]]; then

    if [[ ! -f "$stage_done_file" ]]; then
      bc_stages_${stage}_devtools
      bc_local_run touch $stage_done_file
    fi

  fi

}

function bc_stages_run {
  local pn=$1
  local pv=$2

  bc_stages_env_base $pn $pv
  bc_stages_env_base_mkdirs
  . "$BC_P_FILE" || bc_error "problem sourcing package file"
  bc_stages_env_package

  for stage in ${BC_STAGES_ALL[@]}; do
    bc_stage_$stage
  done

  bc_stages_env_package_clear
  bc_stages_env_base_clear
}

function bc_stage_fetch {
  mkdir -p "$BC_S_DIR"

  bc_pushd "$BC_S_DIR"
    bc_stage_run fetch
  bc_popd
}

function bc_stage_unpack {
  mkdir -p "$BC_W_DIR"

  bc_pushd "$BC_W_DIR"
    bc_stage_run unpack
  bc_popd
}

function bc_stage_patch {
  mkdir -p "$BC_W_DIR"

  bc_pushd "$BC_W_DIR"
    bc_stage_run patch
  bc_popd
}

function bc_stage_configure {
  mkdir -p "$BC_W_DIR"
  mkdir -p "$BC_PKG_BUILD_DIR"

  bc_pushd "$BC_W_DIR"
    bc_stage_run configure
  bc_popd
}

function bc_stage_build {
  mkdir -p "$BC_W_DIR"

  bc_pushd "$BC_W_DIR"
    bc_stage_run build
  bc_popd
}

function bc_stage_install {
  mkdir -p "$BC_W_DIR"

  bc_pushd "$BC_W_DIR"
    bc_stage_run install
  bc_popd
}

function bc_stage_framework {
  mkdir -p "$BC_I_DIR"

  bc_pushd "$BC_I_DIR"
    bc_stage_run framework
  bc_popd
}

function bc_stage_test {
  echo bc_stage_test
}

function bc_stage_pkgbuild {
  mkdir -p "$BC_I_DIR"
  mkdir -p "$BC_D_DIR"

  bc_pushd "$BC_I_DIR"
    bc_stage_run pkgbuild
  bc_popd
}

function bc_stage_productbuild {
  mkdir -p "$BC_D_DIR"

  bc_pushd "$BC_D_DIR"
    bc_stage_run productbuild
  bc_popd
}
