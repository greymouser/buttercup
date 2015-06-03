
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

  find . > "$BC_D_DIR/$BC_PKG_P.manifest"

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
#
#   local dist_xml_file="distribution.xml"
#
#   cat <<ENDOFFILE > "$pkg_dir/$dist_xml_file"
# <?xml version="1.0" encoding="utf-8" standalone="no"?>
# <installer-gui-script minSpecVersion="1">
#
#   <title>$src_name</title>
#   <organization>$organization</organization>
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
#   <pkg-ref id="$identifier"
#            version="0"
#            auth="root">$pkgbuild_output</pkg-ref>
#
#   <!-- List them again here. They can now be organized as a hierarchy if you want. -->
#   <choices-outline>
#     <line choice="$identifier"/>
#   </choices-outline>
#
#   <!-- Define each choice above -->
#   <choice id="$identifier"
#           visible="false"
#           title="$src_name"
#           description="$src_homepage"
#           start_selected="true">
#     <pkg-ref id="$identifier"/>
#   </choice>
#
# </installer-gui-script>
# ENDOFFILE
#
#   stage_done_file=".$src_designation.productbuild"
#   if [[ ! -f "$stage_done_file" ]]; then
#
#     pushd "$pkg_dir"
#     #--resources resources \
#     $(xc_run --find productbuild)     \
#       --distribution "$dist_xml_file" \
#       --package-path .                \
#       --version $src_version          \
#       "$pkg_dir/$productbuild_output" || error_report productbuild
#     popd
#
#     touch "$stage_done_file"
#   fi
# }
