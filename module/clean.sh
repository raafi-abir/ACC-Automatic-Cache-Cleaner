#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common.sh"

LOCK=/dev/.cache_cleaner.lock   # /dev is tmpfs, so a stale lock can't survive a reboot
if ! mkdir "$LOCK" 2>/dev/null; then
  echo "Another cleanup is already running."
  exit 1
fi
trap 'rmdir "$LOCK" 2>/dev/null' EXIT
trap 'exit 1' INT TERM

cache_kb=0; corpse_kb=0; corpse_n=0; junk_kb=0
echo "Started: $($DATE '+%Y-%m-%d %H:%M:%S')"

# ---------- 1. App cache ----------
if [ "$CLEAN_CACHE" = 1 ]; then
  echo "- Cleaning app cache..."
  fg=$(foreground_pkg)
  [ -n "$fg" ] && echo "  skipping foreground app: $fg"
  for d in $CACHE_GLOBS; do
    [ -d "$d" ] || continue
    pkg=${d%/cache}; pkg=${pkg%/code_cache}; pkg=${pkg##*/}
    is_excluded "$pkg" && continue
    [ -n "$fg" ] && [ "$pkg" = "$fg" ] && continue
    cache_kb=$((cache_kb + $(wipe_measured "$d")))
  done
fi

# ---------- 2. Corpse finder ----------
if [ "$CLEAN_CORPSES" = 1 ]; then
  echo "- Looking for leftovers of uninstalled apps..."
  for udir in /data/media/[0-9]*; do
    [ -d "$udir" ] || continue
    uid=${udir##*/}
    list="$DATA/installed_$uid.txt"
    pm list packages --user "$uid" 2>/dev/null | sed 's/^package://' > "$list"
    n=$(( $(wc -l < "$list") + 0 ))
    if [ "$n" -lt 20 ]; then
      echo "  user $uid: package list looks incomplete ($n), skipped for safety"
      continue
    fi
    bases="$udir/Android/data $udir/Android/obb"
    [ "$uid" = 0 ] && bases="$bases /data/media/obb"
    for base in $bases; do
      [ -d "$base" ] || continue
      for d in "$base"/*; do
        [ -d "$d" ] || continue
        name=${d##*/}
        echo "$name" | grep -Eq '^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z0-9_]+)+$' || continue
        grep -qxF "$name" "$list" && continue
        is_excluded "$name" && continue
        s=$(dir_kb "$d")
        rm -rf "$d"
        corpse_kb=$((corpse_kb + s))
        corpse_n=$((corpse_n + 1))
        echo "  removed leftover: $name"
      done
    done
  done
  rm -f "$DATA"/installed_*.txt
fi

# ---------- 3. Superfluous data ----------
if [ "$CLEAN_JUNK" = 1 ]; then
  echo "- Removing logs and junk..."
  for p in /data/tombstones /data/anr /data/system/dropbox \
           /data/media/*/.thumbnails /data/media/*/DCIM/.thumbnails \
           /data/media/*/Pictures/.thumbnails /data/media/*/LOST.DIR; do
    [ -d "$p" ] || continue
    junk_kb=$((junk_kb + $(wipe_measured "$p")))
  done
  logcat -b all -c 2>/dev/null
fi

# ---------- Result ----------
total=$((cache_kb + corpse_kb + junk_kb))
echo
echo "Cache:     $(fmt_size $cache_kb)"
echo "Leftovers: $(fmt_size $corpse_kb) ($corpse_n folders)"
echo "Junk:      $(fmt_size $junk_kb)"
echo "TOTAL:     $(fmt_size $total)"
notify "Cleaned $(fmt_size $total) (cache $(fmt_size $cache_kb), leftovers $(fmt_size $corpse_kb), junk $(fmt_size $junk_kb))"

update_description
exit 0
