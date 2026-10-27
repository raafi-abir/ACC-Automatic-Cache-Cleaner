#!/system/bin/sh
SKIPUNZIP=0
DATA=/data/adb/cache_cleaner
mkdir -p "$DATA"

if [ ! -f "$DATA/config.sh" ]; then
cat > "$DATA/config.sh" <<'CFG'
# Auto Cache Cleaner settings (1 = on, 0 = off)
RUN_HOUR=0          # hour of day (0-23) after which the daily run happens; 0 = 12:00 AM
CLEAN_CACHE=1       # app cache + code_cache (internal and external)
CLEAN_CORPSES=1     # leftover Android/data and Android/obb folders of uninstalled apps
CLEAN_JUNK=1        # tombstones, ANR traces, dropbox logs, thumbnails, LOST.DIR, logcat
SHOW_TOAST=1        # show result toast/notification
SCAN_INTERVAL_MIN=60 # how often (minutes) the live cache size in the module card refreshes
CFG
fi
[ -f "$DATA/exclude.txt" ] || printf '# One package name per line. These are never cleaned.\n' > "$DATA/exclude.txt"

set_perm_recursive "$MODPATH" 0 0 0755 0755
ui_print "- ACC - Automatic Cache Cleaner by raafi-abir"
ui_print "- github.com/raafi-abir"
ui_print "- Runs daily at 12:00 AM (config: $DATA/config.sh)"
ui_print "- Use the module's Action button to run it manually"
