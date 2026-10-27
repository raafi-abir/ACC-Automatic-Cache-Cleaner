#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common.sh"

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 10; done
sleep 60

STATE=$DATA/last_run_day
today() { $DATE +%Y%m%d; }
[ -f "$STATE" ] || today > "$STATE"

update_description
ticks=0

# 'sleep' doesn't count time spent in deep sleep, so instead of one long sleep we poll the
# wall clock. If the phone was asleep at midnight, the run happens as soon as it wakes.
while true; do
  load_config
  d=$(today)
  h=$($DATE +%H); h=${h#0}; h=${h:-0}
  last=$(cat "$STATE" 2>/dev/null)
  if [ "$d" != "$last" ] && [ "$h" -ge "$RUN_HOUR" ]; then
    echo "$d" > "$STATE"
    sh "$MODDIR/clean.sh" > "$LOG" 2>&1
    ticks=0
  fi
  sleep 60
  ticks=$((ticks + 1))
  if [ "$ticks" -ge "$SCAN_INTERVAL_MIN" ]; then
    update_description
    ticks=0
  fi
done
