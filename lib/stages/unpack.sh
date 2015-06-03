
function bc_stages_unpack_default {

  for url in $BC_PKG_PATCHES $BC_PKG_SOURCES; do

    if [[ "${url:0:4}" == "git|" ]]; then
      url=${url:4}
      tag=$(echo $url | cut -f2 -d'|')
      url=$(echo $url | cut -f1 -d'|')

      bc_pushd "$BC_S_DIR/$BC_PKG_PN"
        bc_xc_run                         \
          git archive                     \
          --format=tar                    \
          --prefix=$BC_PKG_P/             \
          $tag                            \
          | (cd "$BC_W_DIR" && tar xf -)  \
          || bc_error git unpack
      bc_popd

    else

      url="$(basename $url)"

      if [[ "${url: -6}" == "tar.gz" ]]; then
        cmd="tar xzf $BC_S_DIR/$url"
        bc_local_run $cmd || bc_error unpack
      elif [[ "${url: -7}" == "tar.bz2" ]]; then
        cmd="tar xjf $BC_S_DIR/$url"
        bc_local_run $cmd || bc_error unpack
      elif [[ "${url: -3}" == "gz" ]]; then
        cmd="gunzip $BC_S_DIR/$url"
        bc_local_run $cmd || bc_error unpack
      elif [[ "${url: -4}" == "bz2" ]]; then
        cmd="bunzip2 $BC_S_DIR/$url"
        bc_local_run $cmd || bc_error unpack
      else
        echo "unknown package format, not unpacking automatically"
      fi

    fi

  done

}
