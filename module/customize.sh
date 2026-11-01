SKIPUNZIP=0

ui_print "- Installing InstallerX Revived as MIUI PackageInstaller..."
set_perm_recursive "$MODPATH/product" 0 0 0755 0644
