
function bc_stages_install_default {

  bc_pushd "$BC_PKG_BUILD_DIR"
    bc_xc_run $MAKE $MAKE_OPTS  \
      install                   \
      DESTDIR="$BC_I_DIR"       \
      || bc_error build
  bc_popd

}

function bc_stages_install_devtools {

  bc_stages_install_default

  bc_pushd "$BC_I_DIR"
    tar cpf - * | tar xmpf - -C /
  bc_popd

}
