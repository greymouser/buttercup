
function bc_stages_fetch_default {

  for url in $BC_PKG_PATCHES $BC_PKG_SOURCES; do

    if [[ "${url:0:4}" == "git|" ]]; then
      # prune the prefix "git:" -- internal moniker for using git
      url=${url:4}
      tag=$(echo $url | cut -f2 -d'|')
      url=$(echo $url | cut -f1 -d'|')

      if [[ ! -d "$BC_PKG_PN" ]]; then
        bc_xc_run git clone $url $BC_PKG_PN || bc_error git
      else
        bc_pushd "$BC_PKG_PN"
        bc_xc_run git pull || bc_error git
        bc_popd
      fi

    elif [[ "${url:0:5}"  == "http:"  ]]      \
      || [[ "${url:0:6}"  == "https:" ]]      \
      || [[ "${url:0:4}"  == "ftp:"   ]]; then

      local curl_opts="-O"
      local protocol=""
      case "${url:0:6}" in
        https*)
          protocol="https"
          curl_opts="-L $curl_opts"
          ;;
        http*)
          protocol="http"
          curl_opts="-L $curl_opts"
          ;;

        ftp*)
          protocol="ftp"
          ;;
      esac

      cmd="curl $curl_opts $url"
      echo $cmd
      bc_xc_run $cmd || bc_error $protocol

    elif [[ "${url:0:5}" == "file:"  ]]; then
      # prune the prefix "file://" -- internal moniker for using cp
      url="${url:7}"
      bc_local_run cp -a $url .
    fi

  done

}
