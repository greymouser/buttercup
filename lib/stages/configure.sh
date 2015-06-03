
#-------------------------------------------------------------------------------
# Common autotools-ish options

# Installation directories:
#   --prefix=PREFIX         install architecture-independent files in PREFIX
#                           [/usr/local]
#   --exec-prefix=EPREFIX   install architecture-dependent files in EPREFIX
#                           [PREFIX]
#
# By default, `make install' will install all the files in
# `/usr/local/bin', `/usr/local/lib' etc.  You can specify
# an installation prefix other than `/usr/local' using `--prefix',
# for instance `--prefix=$HOME'.
#
# For better control, use the options below.
# --bindir=DIR            user executables [EPREFIX/bin]
# --sbindir=DIR           system admin executables [EPREFIX/sbin]
# --libexecdir=DIR        program executables [EPREFIX/libexec]
# --sysconfdir=DIR        read-only single-machine data [PREFIX/etc]
# --sharedstatedir=DIR    modifiable architecture-independent data [PREFIX/com]
# --localstatedir=DIR     modifiable single-machine data [PREFIX/var]
# --libdir=DIR            object code libraries [EPREFIX/lib]
# --includedir=DIR        C header files [PREFIX/include]
# --oldincludedir=DIR     C header files for non-gcc [/usr/include]
# --datarootdir=DIR       read-only arch.-independent data root [PREFIX/share]
# --datadir=DIR           read-only architecture-independent data [DATAROOTDIR]
# --infodir=DIR           info documentation [DATAROOTDIR/info]
# --localedir=DIR         locale-dependent data [DATAROOTDIR/locale]
# --mandir=DIR            man documentation [DATAROOTDIR/man]
# --docdir=DIR            documentation root [DATAROOTDIR/doc/xxxxxx]
# --htmldir=DIR           html documentation [DOCDIR]
# --dvidir=DIR            dvi documentation [DOCDIR]
# --pdfdir=DIR            pdf documentation [DOCDIR]
# --psdir=DIR             ps documentation [DOCDIR]
#
# Program names:
# --program-prefix=PREFIX            prepend PREFIX to installed program names
# --program-suffix=SUFFIX            append SUFFIX to installed program names
# --program-transform-name=PROGRAM   run sed PROGRAM on installed program names


#-------------------------------------------------------------------------------
# Goal:

# /usr/local/etc/foo.conf
# /usr/local/var/foo/*
# /usr/local/bin/foo
# /usr/local/sbin/sfoo
# /usr/local/share/man/man.?/foo.{1,3,?}
# /Library/Frameworks/foo.framework/$VERSION/
# /Library/Frameworks/foo.framework/$VERSION/Headers
# /Library/Frameworks/foo.framework/$VERSION/Libraries
# /Library/Frameworks/foo.framework/$VERSION/Documentation
# /Library/Frameworks/foo.framework/$VERSION/Resources

#-------------------------------------------------------------------------------

function bc_stages_configure_env {

  BC_PKG_CONFIGURE_PREFIX="$BC_PKG_FRAMEWORK_PREFIX"
  BC_PKG_CONFIGURE_EPREFIX="$BC_PKG_FRAMEWORK_PREFIX"

  BC_PKG_CONFIGURE_BIN="/usr/local/bin"
  BC_PKG_CONFIGURE_SBIN="/usr/local/sbin"
  BC_PKG_CONFIGURE_LIBEXEC="$BC_PKG_CONFIGURE_EPREFIX/bin"

  BC_PKG_CONFIGURE_SYSCONF="/usr/local/etc/$BC_PKG_PN"

  BC_PKG_CONFIGURE_STATE_LOCAL="/usr/local/var/$BC_PKG_PN"
  BC_PKG_CONFIGURE_STATE_SHARED="$BC_PKG_CONFIGURE_STATE_LOCAL"

  BC_PKG_CONFIGURE_LIB="$BC_PKG_CONFIGURE_EPREFIX/Libraries"

  BC_PKG_CONFIGURE_INCLUDE="$BC_PKG_CONFIGURE_PREFIX/Headers"

  BC_PKG_CONFIGURE_DATA_ROOT="$BC_PKG_CONFIGURE_PREFIX/Resources"
  BC_PKG_CONFIGURE_MAN="/usr/local/share/man"
  BC_PKG_CONFIGURE_DOC="$BC_PKG_CONFIGURE_PREFIX/Documentation"

  BC_PKG_CONFIGURE_OPTS="
--build=$GCC_TRIPLET_BUILD_TYPE
--host=$GCC_TRIPLET_HOST_TYPE
--prefix=$BC_PKG_CONFIGURE_PREFIX
--exec-prefix=$BC_PKG_CONFIGURE_EPREFIX
--bindir=$BC_PKG_CONFIGURE_BIN
--sbindir=$BC_PKG_CONFIGURE_SBIN
--libexecdir=$BC_PKG_CONFIGURE_LIBEXEC
--sysconfdir=$BC_PKG_CONFIGURE_SYSCONF
--sharedstatedir=$BC_PKG_CONFIGURE_STATE_SHARED
--localstatedir=$BC_PKG_CONFIGURE_STATE_LOCAL
--libdir=$BC_PKG_CONFIGURE_LIB
--includedir=$BC_PKG_CONFIGURE_INCLUDE
--datarootdir=$BC_PKG_CONFIGURE_DATA_ROOT
--mandir=$BC_PKG_CONFIGURE_MAN
--docdir=$BC_PKG_CONFIGURE_DOC
--disable-dependency-tracking
$BC_PKG_CONFIGURE_EXTRA_OPTS
"
}

function bc_stages_configure_default {

  bc_stages_configure_env

  bc_pushd "$BC_PKG_BUILD_DIR"

  $BC_PKG_CONFIGURE_SCRIPT \
    $BC_PKG_CONFIGURE_OPTS \
    DESTDIR="$BC_I_DIR"    \
    || bc_error configure

  bc_popd

}
