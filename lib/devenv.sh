
function bc_devenv_install {

  bc_pushd ${BC_TOP_DIR}

    mkdir -p "$BC_DEVTOOLS_DIR"

    bc_local_run npm install

    bc_stages_run autoconf 2.59
    bc_stages_run fop 2.0

  bc_popd

}
