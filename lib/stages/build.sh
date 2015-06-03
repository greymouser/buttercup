
function bc_stages_build_default {

  bc_pushd "$BC_PKG_BUILD_DIR"

  bc_xc_run $MAKE $MAKE_OPTS  \
    DESTDIR="$BC_I_DIR"       \
    || bc_error build

  bc_popd

}
