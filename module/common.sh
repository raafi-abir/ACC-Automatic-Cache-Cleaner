#!/system/bin/sh
# Shared helpers - ACC by raafi-abir (github.com/raafi-abir)
MODDIR=${MODDIR:-${0%/*}}
DATA=${CC_DATA:-/data/adb/cache_cleaner}
CONF=$DATA/config.sh
EXCLUDE=$DATA/exclude.txt
LOG=$DATA/last_run.log
# toybox date (bionic) honours the Android timezone; busybox's static date does not
DATE=/system/bin/date
mkdir -p "$DATA"
touch "$EXCLUDE"

CACHE_GLOBS="/data/user/*/*/cache /data/user/*/*/code_cache \
/data/user_de/*/*/cache /data/user_de/*/*/code_cache \
/data/media/*/Android/data/*/cache"

load_config() {
  RUN_HOUR=0; CLEAN_CACHE=1; CLEAN_CORPSES=1; CLEAN_JUNK=1; SHOW_TOAST=1; SCAN_INTERVAL_MIN=5
  [ -f "$CONF" ] && . "$CONF"
  HAS_EXCL=$(grep -Ecv '^[[:space:]]*(#|$)' "$EXCLUDE" 2>/dev/null)
  [ "${HAS_EXCL:-0}" -gt 0 ] 2>/dev/null || HAS_EXCL=0
}
load_config

is_excluded() {
  [ "$HAS_EXCL" = 0 ] && return 1
  grep -qxF "$1" "$EXCLUDE" 2>/dev/null
}

# size of a path in KB
dir_kb() { set -- $(du -sk "$1" 2>/dev/null); echo "${1:-0}"; }

# delete everything inside a directory but keep the directory (keeps owner/SELinux label)
wipe_contents() { rm -rf "$1"/* "$1"/.[!.]* 2>/dev/null; }

# wipe a dir's contents and print KB freed (an empty dir itself reports 4 KB, so subtract it)
wipe_measured() {
  _s=$(dir_kb "$1")
  if [ "$_s" -gt 4 ] 2>/dev/null; then wipe_contents "$1"; echo $((_s - 4)); else echo 0; fi
}

fmt_size() {
  kb=${1:-0}
  if [ "$kb" -ge 1048576 ]; then
    echo "$((kb / 1048576)).$(( (kb % 1048576) * 10 / 1048576 )) GB"
  elif [ "$kb" -ge 1024 ]; then
    echo "$((kb / 1024)).$(( (kb % 1024) * 10 / 1024 )) MB"
  else
    echo "${kb} KB"
  fi
}

# Total cache that a cleanup would free right now (nothing is deleted). One du call for speed.
cache_scan_kb() {
  du -sk $CACHE_GLOBS 2>/dev/null | {
    t=0
    while read -r s p; do
      [ "$s" -gt 4 ] 2>/dev/null || continue
      pkg=${p%/cache}; pkg=${pkg%/code_cache}; pkg=${pkg##*/}
      is_excluded "$pkg" && continue
      t=$((t + s - 4))
    done
    echo "$t"
  }
}

# Writes the live cache size into module.prop's description (shown in the manager's module card)
update_description() {
  _kb=$(cache_scan_kb)
  _new="description=Cache: $(fmt_size "${_kb:-0}")"
  _old=$(grep '^description=' "$MODDIR/module.prop" 2>/dev/null)
  [ "$_new" = "$_old" ] && return 0
  sed -i "s|^description=.*|$_new|" "$MODDIR/module.prop"
}

# Toast via helper app if present, otherwise a notification posted as the shell user.
notify() {
  [ "$SHOW_TOAST" = 1 ] || return 0
  _msg="$1"
  if pm path bellavita.toast >/dev/null 2>&1; then
    am start --user 0 -a android.intent.action.MAIN -e toasttext "$_msg" \
      -n bellavita.toast/.MainActivity >/dev/null 2>&1
    return 0
  fi
  if command -v setuidgid >/dev/null 2>&1; then
    setuidgid 2000 cmd notification post -S bigtext -t "ACC" cache_cleaner "$_msg" >/dev/null 2>&1
  else
    su 2000 -c "cmd notification post -S bigtext -t 'ACC' cache_cleaner '$_msg'" >/dev/null 2>&1
  fi
}
