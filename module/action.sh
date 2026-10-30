#!/system/bin/sh
# Runs when you tap "Action" on the module in the Magisk / KernelSU app
MODDIR=${0%/*}
echo "ACC - Automatic Cache Cleaner"
echo "github.com/raafi-abir"
echo
sh "$MODDIR/clean.sh"
