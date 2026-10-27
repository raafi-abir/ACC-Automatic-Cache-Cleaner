#!/bin/sh
# Builds dist/ACC-Automatic-Cache-Cleaner-<version>.zip from ./module
set -e
cd "$(dirname "$0")"
ver=$(grep '^version=' module/module.prop | cut -d= -f2)
mkdir -p dist
rm -f "dist/ACC-Automatic-Cache-Cleaner-$ver.zip"
# reset the live description so the release doesn't ship a stale number
sed -i 's|^description=.*|description=Cache: calculating...|' module/module.prop
(cd module && zip -r9 "../dist/ACC-Automatic-Cache-Cleaner-$ver.zip" . -x '.*')
echo "Built dist/ACC-Automatic-Cache-Cleaner-$ver.zip"
