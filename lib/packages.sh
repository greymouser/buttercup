
declare -A BC_PACKAGES

function bc_package_init {

  local pn="$1"
  local pnv=""
  local pv=""
  local pversions=""
  local max="0.0.0"

  for file in $(ls -1 "$BC_PACKAGES_DIR"/$pn/$pn*); do
    file=$(basename $file)
    pnv=${file//.package}
    pv=${pnv#${pn}-}
    if [[ "" == "$pversions" ]]; then
      pversions="$pv"
    else
      pversions="$pversions $pv"
    fi

    if bc_local_run semver --range ">$max" "$pv" >/dev/null; then
      max=$pv
    fi
  done

  if [[ "" == "${BC_PACKAGES["packages"]}" ]]; then
    BC_PACKAGES["packages"]="$pn"
  else
    BC_PACKAGES["packages"]=$(echo ${BC_PACKAGES["packages"]} $pn \
                              |tr " " "\n"                        \
                              |sort                               \
                              |tr "\n" " ")
  fi

  BC_PACKAGES["$pn versions"]="$pversions"
  BC_PACKAGES["$pn max"]="$max"

}

function bc_packages_init {

  pushd "$BC_TOP_DIR"

  for package in $(ls -1 "$BC_PACKAGES_DIR"); do
    bc_package_init $package
  done

  popd

}

function bc_package_list {

  local pn=$1
  local pn_max=${BC_PACKAGES["$pn max"]}
  local pn_versions=${BC_PACKAGES["$pn versions"]}
  local output="$pn:"

  for version in $pn_versions; do
    if [[ "$pn_max" == "$version" ]]; then
      output+=" [$version]"
    else
      output+=" $version"
    fi
  done

  echo $output

}

function bc_packages_list {

  local packages=""

  for pn in ${BC_PACKAGES["packages"]}; do
    echo $(bc_package_list $pn)
  done

}
