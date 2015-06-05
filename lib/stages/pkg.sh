
# $ pkgbuild --analyze --root unixodbc-2.3.2 unixodbc-2.3.2.plist
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <array>
# 	<dict>
# 		<key>BundleIsVersionChecked</key>
# 		<true/>
# 		<key>BundleOverwriteAction</key>
# 		<string>upgrade</string>
# 		<key>RootRelativeBundlePath</key>
# 		<string>Library/Frameworks/unixODBC.framework</string>
# 	</dict>
# </array>
# </plist>
#
# $ pkgbuild --root unixodbc-2.3.2/ --component-plist unixodbc-2.3.2.plist unixodbc-2.3.2.pkg


function bc_stages_pkgbuild_default {

#   cat <<UNINSTALL_SCRIPT > "$BC_PKG_FRAMEWORK_DIR/uninstall.sh"
#   SCRIPT_FILE="\${BASH_SOURCE[0]}"
#   cp /Library/Frameworks/$BC_PKG_FRAMEWORK_DIR/uninstall.sh /tmp/uninstall-
# UNINSTALL_SCRIPT

  local manifest="$BC_D_DIR/$BC_PKG_P.manifest"
  bc_local_run find -d . > $manifest \
    || bc_error manifest

  bc_local_run sed                              \
    -f $BC_LIB_DIR/stages/pkg.sed-manifest-cmds \
    -i .bk                                      \
    $manifest                                   \
    || bc_error manifest_sed

  bc_pushd "$BC_D_DIR"

  cat <<PKG_PLIST > "$BC_PKG_P.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
	<dict>
		<key>BundleIsVersionChecked</key>
		<true/>
		<key>BundleOverwriteAction</key>
		<string>upgrade</string>
		<key>RootRelativeBundlePath</key>
		<string>Library/Frameworks/$BC_PKG_PN.framework</string>
	</dict>
</array>
</plist>
PKG_PLIST

  bc_xc_run pkgbuild                  \
    --root "$BC_I_DIR/"               \
    --component-plist $BC_PKG_P.plist \
    $BC_PKG_P.pkg                     \
    || bc_error pkgbuild

  bc_popd

}


#---
# Example productbuild stage when I get there
# organization="org.unixodbc"
# identifier="$organization.unixodbc"
# pkgbuild_output="$src_designation.bin.pkg"
# productbuild_output="$src_designation.pkg"

# function x_productbuild () {
# function bc_stages_productbuild_default {
#
#   bc_pushd "$BC_D_DIR"
#
#     local dist_xml_file="distribution.xml"
#
#     cat <<ENDOFFILE > "$dist_xml_file"
# <?xml version="1.0" encoding="utf-8" standalone="no"?>
# <installer-gui-script minSpecVersion="1">
#
#   <title>$BC_PKG_PN</title>
#   <organization>$BC_PKG_ORGANIZATION</organization>
#   <domains enable_localSystem="true"/>
#   <options customize="never" require-scripts="true" rootVolumeOnly="true" />
#
#   <!-- Define documents displayed at various steps -->
#   <!--
#   <welcome    file="welcome.html"    mime-type="text/html" />
#   <license    file="license.html"    mime-type="text/html" />
#   <conclusion file="conclusion.html" mime-type="text/html" />
#   -->
#
#   <!-- List all component packages -->
#   <pkg-ref id="org.erlang.otp"
#            version="0"
#            auth="root">$BC_DIST_DIR/erlang/otp-17.5.6.pkg</pkg-ref>
#
#   <pkg-ref id="org.elixir-lang.elixir"
#           version="0"
#           auth="root">$BC_DIST_DIR/elixir/elixir-1.0.4.pkg</pkg-ref>
#
#   <pkg-ref id="org.unixodbc.unixODBC"
#           version="0"
#           auth="root">$BC_DIST_DIR/unixodbc/unixODBC-2.3.2.pkg</pkg-ref>
#
#   <pkg-ref id="org.wxwidgets.wxWidgets"
#           version="0"
#           auth="root">$BC_DIST_DIR/wxwidgets/wxWidgets-3.0.2.pkg</pkg-ref>
#
#   <!-- List them again here. They can now be organized as a hierarchy if you want. -->
#   <choices-outline>
#     <line choice="org.erlang.otp"/>
#     <line choice="org.elixir-lang.elixir"/>
#     <line choice="org.wxwidgets.wxWidgets"/>
#     <line choice="org.unixodbc.unixODBC"/>
#   </choices-outline>
#
#   <!-- Define each choice above -->
#   <choice id="org.erlang.otp"
#           visible="false"
#           title="Erlang/OTP 17.5.6"
#           description="http://www.erlang.org"
#           start_selected="true">
#     <pkg-ref id="org.erlang.otp"/>
#   </choice>
#
#   <choice id="org.elixir-lang.elixir"
#           visible="true"
#           title="Elixir 1.0.4"
#           description="http://www.elixir-lang.org"
#           start_selected="true">
#     <pkg-ref id="org.elixir-lang.elixir"/>
#   </choice>
#
#   <choice id="org.wxwidgets.wxWidgets"
#           visible="true"
#           title="wxWidgets 3.0.2"
#           description="http://www.wxwidgets.org"
#           start_selected="true">
#     <pkg-ref id="org.wxwidgets.wxWidgets"/>
#   </choice>
#
#   <choice id="org.unixodbc.unixODBC"
#           visible="true"
#           title="unixODBC 2.3.2"
#           description="http://www.unixodbc.org"
#           start_selected="true">
#     <pkg-ref id="org.unixodbc.unixODBC"/>
#   </choice>
#
# </installer-gui-script>
# ENDOFFILE
#
#     bc_xc_run productbuild            \
#       --distribution "$dist_xml_file" \
#       --package-path .                \
#       --version $BC_PKG_PV            \
#       "$BC_PKG_P.pkg"                 \
#       || bc_error productbuild
#
#   bc_popd
#
# }
