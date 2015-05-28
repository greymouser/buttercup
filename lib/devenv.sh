
function bc_devenv_install {

  pushd ${BC_TOP_DIR}

  mkdir -p "$BC_DEVTOOLS_DIR"
  bc_local_run npm install

  popd

}
