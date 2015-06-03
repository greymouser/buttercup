
#-------------------------------------------------------------------------------
# Set the deployment target for the macosx or ios platform.
# This is the minimum supported platform.

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

MACOSX_DEPLOYMENT_TARGET="10.9"
MACOSX_BASE_SDK="10.10"
DEPLOY_SDK="macosx$MACOSX_DEPLOYMENT_TARGET"
BASE_SDK="macosx$MACOSX_BASE_SDK"

#-------------------------------------------------------------------------------
# Set clang / gcc-esque arch and os variables for later use
ARCH="x86_64"
MARCH="x86-64"
VENDOR="apple"

# OS_NAME=$(uname -s | tr '[:upper:]' '[:lower:]')
# OS_VERSION=$(uname -r)
OS_NAME="darwin"
OS_VERSION="13.4.0" # 10.9.5 was 13.4.0
OS="$OS_NAME$OS_VERSION"

GCC_TRIPLET_BUILD_TYPE="$ARCH-$VENDOR-$OS"
GCC_TRIPLET_HOST_TYPE="$GCC_TRIPLET_BUILD_TYPE"

CLANG_TARGET_TYPE="$ARCH-$VENDOR-$DEPLOY_SDK"


#-------------------------------------------------------------------------------
# Xcode developer paths

XCODE_SELECT="/usr/bin/xcode-select"
XCODE_DEVELOPER_PATH="$($XCODE_SELECT -p)"

XCRUN="$XCODE_DEVELOPER_PATH/usr/bin/xcrun"
XCRUN_OPTS="--sdk $BASE_SDK"
XCRUN_CMD="$XCRUN $XCRUN_OPTS"

function bc_xc_find {
  local tool_name="$1"
  [[ "" == "$1" ]] && echo "No tool '$1'" && exit 1
  $XCRUN_CMD --find $1
}

function bc_xc_run {
  local tool_name="$1"
  [[ "" == "$1" ]] && echo "No tool '$1'" && exit 1
  $XCRUN_CMD $1 ${*:2}
}

function bc_local_run {
  local tool_name="$1"
  [[ "" == "$1" ]] && echo "No tool '$1'" && exit 1
  PATH="/usr/local/bin:$PATH" $1 ${*:2}
}


#-------------------------------------------------------------------------------
# SDK helper env vars

SDK_PATH=$($XCRUN_CMD --show-sdk-path)
SDK_VERSION=$($XCRUN_CMD --show-sdk-version)
SDK_PLATFORM_PATH=$($XCRUN_CMD --show-sdk-platform-path)
SDK_PLATFORM_VERSION=$($XCRUN_CMD --show-sdk-platform-version)

SDKROOT="$SDK_PATH"
ADDITIONAL_SDKS=""


#-------------------------------------------------------------------------------
# Common build tools and associated env vars

MAKE="$(bc_xc_find make)"
MAKE_OPTS="-j5"

CC="$(bc_xc_find clang)"
CXX="$(bc_xc_find clang++)"
LD="$(bc_xc_find clang)"
#LD="$(bc_xc_find ld)"

CLANG_FLAGS="               \
--target=$CLANG_TARGET_TYPE \
-arch $ARCH                 \
"

CFLAGS="$CLANG_FLAGS                           \
-march=$MARCH                                  \
-mmacosx-version-min=$MACOSX_DEPLOYMENT_TARGET \
-isysroot "$SDK_PATH"                          \
-isystem "$BC_INSTALL_DIR/include"             \
-iframework "$BC_INSTALL_DIR/Frameworks"       \
-iframework "$BC_INSTALL_DIR"                  \
"
CXXFLAGS="$CFLAGS"

CLANG_AS_LD_LDFLAGS="$CLANG_FLAGS                 \
-Wl,-macosx_version_min,$MACOSX_DEPLOYMENT_TARGET \
-Wl,-L,"$BC_INSTALL_DIR/lib"                      \
-Wl,-F,"$BC_INSTALL_DIR/Frameworks"               \
-Wl,-F,"$BC_INSTALL_DIR"                          \
"
LD_AS_LD_LDFLAGS="$CLANG_FLAGS                \
-macosx_version_min $MACOSX_DEPLOYMENT_TARGET \
-L "$BC_INSTALL_DIR/lib"                      \
-F "$BC_INSTALL_DIR/Frameworks"               \
-F "$BC_INSTALL_DIR"                          \
"
LDFLAGS="$CLANG_AS_LD_LDFLAGS"
#LDFLAGS="$LD_AS_LD_LDFLAGS"

YACC="$(bc_xc_find bison) -y"
RANLIB="$(bc_xc_find ranlib)"
AR="$(bc_xc_find ar)"
GETCONF="$(bc_xc_find getconf)"


#-------------------------------------------------------------------------------
export MACOSX_DEPLOYMENT_TARGET SDKROOT ADDITIONAL_SDKS
export MAKE CC CXX LD
export MAKE_OPTS CFLAGS CXXFLAGS LDFLAGS
export YACC RANLIB AR GETCONF
