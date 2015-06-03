
function bc_stages_patch_default {

  bc_pushd "$BC_PKG_SOURCE_DIR"

  for patch_file_url in $BC_PKG_PATCHES; do

    patch_file_url="$(basename $patch_file_url)"

    bc_local_run patch -p1 < $BC_S_DIR/$patch_file_url \
      || bc_error patch $patch_file_url

  done

  bc_popd

}
