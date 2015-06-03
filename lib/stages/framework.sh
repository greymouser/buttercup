
function bc_stages_framework_default {

  bc_pushd "$PWD/$BC_PKG_FRAMEWORK_DIR"

    bc_pushd Versions
      bc_pushd "$BC_PKG_FRAMEWORK_VERSION"

        #bc_local_run ln -shFf Libraries/$BC_PKG_FRAMEWORK_TARGET_UNIX_LIB $BC_PKG_PN
        if [[ -z "$BC_PKG_FRAMEWORK_GENERATE_LIB_LDFLAGS" ]]; then
          bc_error framework must define BC_PKG_FRAMEWORK_GENERATE_LIB_LDFLAGS
        else
          bc_xc_run ld                                    \
            -dylib                                        \
            -arch $ARCH                                   \
            -macosx_version_min $MACOSX_DEPLOYMENT_TARGET \
            -L Libraries                                  \
            $BC_PKG_FRAMEWORK_GENERATE_LIB_LDFLAGS        \
            -o $BC_PKG_PN                                 \
            || bc_error framework ld
        fi

        bc_local_run mkdir -p Resources
      bc_popd
      bc_local_run ln -shFf "$BC_PKG_FRAMEWORK_VERSION" Current
    bc_popd

    bc_local_run ln -shFf "Versions/$BC_PKG_FRAMEWORK_VERSION/$BC_PKG_PN" $BC_PKG_PN

    for dir in Libraries Headers Resources; do
      bc_local_run ln -shFf "Versions/Current/$dir" $dir
    done

    bc_local_run ln -shFf Versions/Current/$BC_PKG_PN $BC_PKG_PN

    cat <<INFO_PLIST > "Resources/Info.plist"
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>English</string>
  <key>CFBundleExecutable</key>
  <string>$BC_PKG_PN</string>
  <key>CFBundleName</key>
  <string>$BC_PKG_PN</string>
  <key>CFBundleGetInfoString</key>
  <string>$BC_PKG_HOMEPAGE</string>
  <key>CFBundleIconFile</key>
  <string></string>
  <key>CFBundleIdentifier</key>
  <string>$BC_PKG_IDENTIFIER</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>$BC_PKG_FRAMEWORK_VERSION</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>$BC_PKG_FRAMEWORK_VERSION</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>CFBundleVersion</key>
  <string>$BC_PKG_PN-$BC_PKG_FRAMEWORK_VERSION</string>
  <key>NSPrincipalClass</key>
  <string></string>
</dict>
</plist>
INFO_PLIST

  bc_popd

}
