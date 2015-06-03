#
#
#-------------------------------------------------------------------------------
#PATH="/usr/bin"                            # xcode-select

# "purify" the PATH
PATH="/usr/bin:/bin"
XCODE_DEVELOPER_PATH=$(/usr/bin/xcode-select -p)

#-------------------------------------------------------------------------------
# $ xcodebuild -showsdks
# OS X SDKs:
# 	OS X 10.9                     	-sdk macosx10.9
# 	OS X 10.10                    	-sdk macosx10.10
#
# iOS SDKs:
# 	iOS 8.3                       	-sdk iphoneos8.3
#
# iOS Simulator SDKs:
# 	Simulator - iOS 8.3           	-sdk iphonesimulator8.3
MACOSX_DEPLOYMENT_TARGET="10.10"
SDK="macosx$MACOSX_DEPLOYMENT_TARGET"

#PATH="$XCODE_DEVELOPER_PATH/usr/bin:" # xcrun

#-------------------------------------------------------------------------------
arch="x86_64"
march="x86-64"
vendor="apple"

os_name=$(uname -s | tr '[:upper:]' '[:lower:]')
os_version=$(uname -r)
os="$os_name$os_version"

triplet_build_type="$arch-$vendor-$os"
triplet_host_type="$build_type"

clang_target_type="$arch-$vendor-$SDK"

#-------------------------------------------------------------------------------
XCRUN="$XCODE_DEVELOPER_PATH/usr/bin/xcrun"
XCRUN_OPTS="--sdk $SDK"
XCRUN_CMD="$XCRUN $XCRUN_OPTS"

function xc_find {
  local tool_name="$1"
  [[ "" == "$1" ]] && echo "No tool '$1'" && exit 1
  $XCRUN_CMD --find $1
}

function xc_run {
  local tool_name="$1"
  [[ "" == "$1" ]] && echo "No tool '$1'" && exit 1
  $XCRUN_CMD $1 ${*:2}
}

#-------------------------------------------------------------------------------
SDK_PATH=$($XCRUN_CMD --show-sdk-path)
SDK_VERSION=$($XCRUN_CMD --show-sdk-version)
SDK_PLATFORM_PATH=$($XCRUN_CMD --show-sdk-platform-path)
SDK_PLATFORM_VERSION=$($XCRUN_CMD --show-sdk-platform-version)
#PATH="$SDK_PATH/usr/bin:$PATH"             # various sdk lib tools

SDKROOT="$SDK_PATH"
ADDITIONAL_SDKS="/"

#-------------------------------------------------------------------------------
# # * `CPP' - C pre-processor.
# CPP="$(xc_find clang)" # cpp, too(?)
#
# # * `CPPFLAGS' - C pre-processor flags.
# CPPFLAGS=

YACC="$(xc_find bison) -y"

#--sysroot=$SDK_PATH                            \
#-isysroot $SDK_PATH                            \
#--target=$clang_target_type                    \

CLANG_FLAGS="                                  \
--target=$clang_target_type                    \
-arch $arch                                    \
-march=$march                                  \
-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET \
-isysroot "$SDK_PATH"                          \
-isystem /usr/include                          \
"
#-I/usr/include                                 \


# CLANG_FLAGS="                                  \
# --target=$clang_target_type                    \
# -arch $arch                                    \
# -march=$march                                  \
# -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET \
# -I /usr/include                                \
# "
# -isysroot "$SDK_PATH"                          \
# -isystem /usr/include                          \
# -iframework /System/Library/Frameworks         \

# CLANG_MACHINE_FLAGS="                          \
# -march=$march                                  \
# -mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET \
# "

# * `CC' - C compiler.
CC="$(xc_find clang)"

# * `CFLAGS' - C compiler flags.
CFLAGS="$CLANG_FLAGS"

# * `CXX' - C++ compiler.
CXX="$(xc_find clang++)"

# * `CXXFLAGS' - C++ compiler flags.
CXXFLAGS="$CFLAGS"

# * `LD' - Linker.
LD="$(xc_find clang)"

LDFLAGS="-L/usr/lib \
$CLANG_FLAGS        \
"

# -Wl,-F"$SDK_PATH/System/Library/Frameworks"       \
# -Wl,-L"$SDK_PATH/usr/lib"                         \
# -Wl,-L/usr/lib                                    \

RANLIB="$(xc_find ranlib)"

# * `AR' - `ar' archiving tool.
AR="$(xc_find ar)"

# * `GETCONF' - `getconf' system configuration inspection tool.
GETCONF="$(xc_find getconf)"

#-------------------------------------------------------------------------------
export MACOSX_DEPLOYMENT_TARGET SDKROOT ADDITIONAL_SDKS
export YACC CC CXX LD RANLIB AR GETCONF
export CFLAGS CXXFLAGS LDFLAGS

#-------------------------------------------------------------------------------
function contains() { # array, element
  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

function error_report () {
  echo "There was a problem with $1"
  exit 1
}

#-------------------------------------------------------------------------------
all_run=(fetch unpack patch configure build install test pkgbuild productbuild)

if [[ "" == "$1" ]]; then
  do_run=${all_run[@]}
elif contains "$1" ${all_run[@]}; then
  do_run=($1)
else
  echo "bad option '$1'"
  exit 1
fi

#-------------------------------------------------------------------------------
top_dir="/Users/greymouser/Projects/erlang/Projects/erlang-framework"

#src_name="otp_src"
src_name="otp"
src_version="17.5.4"

src_designation="$src_name-$src_version"

#src_file="$src_designation.tar.gz"

src_repo="git@github.com:erlang/$src_name.git"
src_repo_version_tag="OTP-$src_version"

src_homepage="http://www.erlang.org/"
patches=""

top_pkg_dir="$top_dir/$src_designation"
src_dir="$top_pkg_dir/src"
build_dir="$top_pkg_dir/build"
dest_dir="$top_pkg_dir/install"
pkg_dir="$top_pkg_dir/pkg"
repos_dir="$top_pkg_dir/repos"

mkdir -p "$src_dir"
mkdir -p "$build_dir"
mkdir -p "$dest_dir"
mkdir -p "$pkg_dir"
mkdir -p "$repos_dir"

#-------------------------------------------------------------------------------
prefix="/usr"
sysconfdir="/private/etc"

organization="org.erlang"
identifier="$organization.otp"
pkgbuild_output="$src_designation.bin.pkg"
productbuild_output="$src_designation.pkg"

export ERL_TOP="$build_dir/$src_repo_version_tag"

#-------------------------------------------------------------------------------
function x_fetch () {
  stage_done_file=".$src_designation.fetch"
  if [[ ! -f "$stage_done_file" ]]; then

    pushd "$src_dir"
    # xc_run curl                                \
    #   -L -O                                    \
    #   http://www.erlang.org/download/$src_file \
    #   || error_report fetch

    for patch_url in $patches; do
      xc_run curl -L -O $patch_url || error_report fetch
    done
    popd

    pushd "$repos_dir"
    if [[ ! -d "$src_name" ]]; then
      xc_run git clone "$src_repo" || error_report fetch
    else
      pushd "$src_name"
      xc_run git pull || error_report fetch
      popd
    fi
    popd

    touch "$stage_done_file"
  fi
}

function x_unpack () {
  stage_done_file=".$src_designation.unpack"
  if [[ ! -f "$stage_done_file" ]]; then

    #pushd "$build_dir"
    #xc_run tar xjf "$src_dir/$src_file" || error_report unpack
    #popd

    pushd "$repos_dir/$src_name"
    xc_run                            \
      git archive                     \
      --format=tar                    \
      --prefix=$src_repo_version_tag/ \
      $src_repo_version_tag           \
      | (cd "$build_dir" && tar xf -) \
      || error_report unpack
    popd

    touch "$stage_done_file"
  fi
}

function x_patch () {
  stage_done_file=".$src_designation.patch"
  if [[ ! -f "$stage_done_file" ]]; then

    touch "$stage_done_file"
  fi
}

function x_configure () {

#--with-dynamic-trace=dtrace   \
  local configure_opts="      \
--build=$triplet_build_type   \
--host=$triplet_host_type     \
--prefix=$prefix              \
--sysconfdir=$sysconfdir      \
--disable-silent-rules        \
--enable-threads              \
--enable-smp-support          \
--enable-kernel-poll          \
--enable-hipe                 \
--enable-darwin-64-bit        \
--enable-m64-build            \
--with-javac                  \
--with-ssl                    \
--with-odbc                   \
--with-wx-config=/usr/bin/wx-config \
--disable-sctp                \
"

  stage_done_file=".$src_designation.configure"
  if [[ ! -f "$stage_done_file" ]]; then

    pushd "$ERL_TOP"
    if [[ ! -f configure ]]; then
      PATH="$PATH:/usr/local/bin" ./otp_build autoconf || error_report configure
    fi

    ./configure                 \
      $configure_opts           \
      DESTDIR="$dest_dir"       \
      || error_report configure
    popd

    touch "$stage_done_file"
  fi
}

function x_build () {
  stage_done_file=".$src_designation.build"
  if [[ ! -f "$stage_done_file" ]]; then

    pushd "$ERL_TOP"
    V=1 xc_run make -j5 DESTDIR="$dest_dir" || error_report build
    popd

    touch "$stage_done_file"
  fi
}

function x_install () {
  stage_done_file=".$src_designation.install"
  if [[ ! -f "$stage_done_file" ]]; then

    mkdir -p "$dest_dir/$prefix"
    mkdir -p "$dest_dir/$sysconfdir"

    pushd "$build_dir/$src_designation-build"
    V=1 xc_run make -j5 install DESTDIR="$dest_dir" || error_report install
    popd

    touch "$stage_done_file"
  fi
}

function x_test () {
  stage_done_file=".$src_designation.test"
  if [[ ! -f "$stage_done_file" ]]; then

    touch "$stage_done_file"
  fi
}

function x_pkgbuild () {
  stage_done_file=".$src_designation.pkgbuild"
  if [[ ! -f "$stage_done_file" ]]; then

    pushd "$pkg_dir"
    $(xc_run --find pkgbuild)     \
      --root "$dest_dir"          \
      --identifier "$identifier"  \
      --version $src_version      \
      --ownership recommended     \
      "$pkgbuild_output"          || error_report pkgbuild
    popd

    touch "$stage_done_file"
  fi
}

function x_productbuild () {

  local dist_xml_file="distribution.xml"

  cat <<ENDOFFILE > "$pkg_dir/$dist_xml_file"
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<installer-gui-script minSpecVersion="1">

  <title>$src_name</title>
  <organization>$organization</organization>
  <domains enable_localSystem="true"/>
  <options customize="never" require-scripts="true" rootVolumeOnly="true" />

  <!-- Define documents displayed at various steps -->
  <!--
  <welcome    file="welcome.html"    mime-type="text/html" />
  <license    file="license.html"    mime-type="text/html" />
  <conclusion file="conclusion.html" mime-type="text/html" />
  -->

  <!-- List all component packages -->
  <pkg-ref id="$identifier"
           version="0"
           auth="root">$pkgbuild_output</pkg-ref>

  <!-- List them again here. They can now be organized as a hierarchy if you want. -->
  <choices-outline>
    <line choice="$identifier"/>
  </choices-outline>

  <!-- Define each choice above -->
  <choice id="$identifier"
          visible="false"
          title="$src_name"
          description="$src_homepage"
          start_selected="true">
    <pkg-ref id="$identifier"/>
  </choice>

</installer-gui-script>
ENDOFFILE

  stage_done_file=".$src_designation.productbuild"
  if [[ ! -f "$stage_done_file" ]]; then

    pushd "$pkg_dir"
    #--resources resources \
    $(xc_run --find productbuild)     \
      --distribution "$dist_xml_file" \
      --package-path .                \
      --version $src_version          \
      "$pkg_dir/$productbuild_output" || error_report productbuild
    popd

    touch "$stage_done_file"
  fi
}

#-------------------------------------------------------------------------------
for step in ${do_run[@]}; do
  echo "$step"
  x_${step}
done
