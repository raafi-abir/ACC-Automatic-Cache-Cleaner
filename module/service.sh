#!/system/bin/sh
MODDIR=${0%/*}
. "$MODDIR/common.sh"

until [ "$(getprop sys.boot_completed)" = "1" ]; do sleep 10; done
sleep 60

rm -f "$DATA/last_run_day"   # state file from versions before v1.2.0 (replaced by last_run_daynum)

update_description
ticks=0

# 'sleep' doesn't count time spent in deep sleep, so instead of one long sleep we poll the
# wall clock. A cleanup missed while the phone was off or asleep runs as soon as it wakes.
while true; do
  reload_if_changed
  if is_due; then
    # clean.sh records the run itself on success; it exits 1 if another run holds the lock
    # (e.g. you tapped Action at the same moment), and then we simply retry on the next poll
    if sh "$MODDIR/clean.sh" > "$LOG.tmp" 2>&1; then
      mv "$LOG.tmp" "$LOG"
    fi
    ticks=0
  fi
  sleep 60
  ticks=$((ticks + 1))
  if [ "$ticks" -ge "$SCAN_INTERVAL_MIN" ]; then
    update_description
    ticks=0
  fi
done
