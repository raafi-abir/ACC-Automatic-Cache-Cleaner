#!/system/bin/sh
# Shared helpers - ACC by raafi-abir (github.com/raafi-abir)
MODDIR=${MODDIR:-${0%/*}}
DATA=${CC_DATA:-/data/adb/cache_cleaner}
CONF=$DATA/config.sh
EXCLUDE=$DATA/exclude.txt
LOG=$DATA/last_run.log
STATE=$DATA/last_run_daynum   # local day number (days since 1970-01-01) of the last cleanup
# toybox date (bionic) honours the Android timezone; busybox's static date does not
DATE=${DATE_CMD:-/system/bin/date}
R=${CC_ROOT:-}   # filesystem prefix, only used by tests; empty on a real device
mkdir -p "$DATA"
touch "$EXCLUDE"

CACHE_GLOBS="$R/data/user/*/*/cache $R/data/user/*/*/code_cache \
$R/data/user_de/*/*/cache $R/data/user_de/*/*/code_cache \
$R/data/media/*/Android/data/*/cache"

# clamp <value> <min> <max> <default>: integer within range, else default (tolerates "08", junk, huge numbers)
clamp() {
  _v=$1
  case "$_v" in ''|*[!0-9]*) echo "$4"; return;; esac
  while [ ${#_v} -gt 1 ] && [ "${_v#0}" != "$_v" ]; do _v=${_v#0}; done
  [ ${#_v} -gt 6 ] && _v=$3
  [ "$_v" -lt "$2" ] && _v=$2
  [ "$_v" -gt "$3" ] && _v=$3
  echo "$_v"
}

load_config() {
  RUN_HOUR=0; CLEAN_CACHE=1; CLEAN_CORPSES=1; CLEAN_JUNK=1; SHOW_TOAST=1; SCAN_INTERVAL_MIN=60
  FREQ=daily; WEEK_DAY=0; MONTH_DAY=1; INTERVAL_DAYS=3
  if [ -f "$CONF" ]; then
    # read KEY=VALUE lines; nothing in the file is ever executed, and CRLF / trailing comments are tolerated
    while IFS='=' read -r _k _v; do
      _k=${_k#"${_k%%[![:space:]]*}"}
      _v=${_v%%#*}; _v=${_v%%[[:space:]]*}
      case "$_k" in
        RUN_HOUR|CLEAN_CACHE|CLEAN_CORPSES|CLEAN_JUNK|SHOW_TOAST|SCAN_INTERVAL_MIN|FREQ|WEEK_DAY|MONTH_DAY|INTERVAL_DAYS)
          eval "$_k=\$_v" ;;
      esac
    done <<CONFEOF
$(tr -d '\r' < "$CONF")
CONFEOF
  fi
  CLEAN_CACHE=$(clamp "$CLEAN_CACHE" 0 1 1)
  CLEAN_CORPSES=$(clamp "$CLEAN_CORPSES" 0 1 1)
  CLEAN_JUNK=$(clamp "$CLEAN_JUNK" 0 1 1)
  SHOW_TOAST=$(clamp "$SHOW_TOAST" 0 1 1)
  RUN_HOUR=$(clamp "$RUN_HOUR" 0 23 0)
  SCAN_INTERVAL_MIN=$(clamp "$SCAN_INTERVAL_MIN" 5 1440 60)
  WEEK_DAY=$(clamp "$WEEK_DAY" 0 6 0)
  MONTH_DAY=$(clamp "$MONTH_DAY" 1 28 1)
  INTERVAL_DAYS=$(clamp "$INTERVAL_DAYS" 1 365 3)
  case "$FREQ" in daily|weekly|monthly|custom) ;; *) FREQ=daily ;; esac
  HAS_EXCL=$(grep -Ecv '^[[:space:]]*(#|$)' "$EXCLUDE" 2>/dev/null)
  [ "${HAS_EXCL:-0}" -gt 0 ] 2>/dev/null || HAS_EXCL=0
}
load_config

# Re-read the settings only when config.sh or exclude.txt changed (keeps the background loop cheap)
reload_if_changed() {
  _m=$DATA/.loaded
  if [ ! -f "$_m" ] || ! [ "$_m" -nt "$CONF" ] || ! [ "$_m" -nt "$EXCLUDE" ]; then
    load_config
    : > "$_m"
  fi
}

# ---------- scheduling ----------
# day_number <year> <month> <day> -> days since 1970-01-01 (pure shell, no timezone surprises)
day_number() {
  _y=$1; _m=${2#0}; _d=${3#0}
  [ "$_m" -le 2 ] && _y=$((_y - 1))
  _era=$((_y / 400))
  _yoe=$((_y - _era * 400))
  _mp=$(( (_m + 9) % 12 ))
  _doy=$(( (153 * _mp + 2) / 5 + _d - 1 ))
  _doe=$(( _yoe * 365 + _yoe / 4 - _yoe / 100 + _doy ))
  echo $(( _era * 146097 + _doe - 719468 ))
}

today_num() { set -- $($DATE '+%Y %m %d'); [ -n "$3" ] && day_number "$1" "$2" "$3"; }
mark_run() { _n=$(today_num); [ -n "$_n" ] && echo "$_n" > "$STATE"; }

# is_due: succeeds when a scheduled cleanup should start now.
# Finds the most recent scheduled day (<= today); due if that slot hasn't been cleaned yet and
# either the slot day has passed (missed while the phone was off/asleep) or RUN_HOUR is reached.
is_due() {
  set -- $($DATE '+%Y %m %d %H %w')
  [ -n "$5" ] || return 1   # date unavailable: never guess
  _today=$(day_number "$1" "$2" "$3")
  _h=${4#0}; _h=${_h:-0}; _dow=$5; _dom=${3#0}
  _last=$(cat "$STATE" 2>/dev/null)
  case "$_last" in ''|*[!0-9]*) _last=$_today; echo "$_last" > "$STATE";; esac   # first run: no immediate cleanup
  [ "$_last" -gt "$_today" ] && { _last=$_today; echo "$_last" > "$STATE"; }      # clock moved backwards
  case "$FREQ" in
    weekly)  _sched=$((_today - (_dow - WEEK_DAY + 7) % 7)) ;;
    monthly)
      if [ "$_dom" -ge "$MONTH_DAY" ]; then
        _sched=$((_today - _dom + MONTH_DAY))
      else
        _py=$1; _pm=${2#0}
        if [ "$_pm" -eq 1 ]; then _pm=12; _py=$((_py - 1)); else _pm=$((_pm - 1)); fi
        _sched=$(day_number "$_py" "$_pm" "$MONTH_DAY")
      fi ;;
    custom)  _sched=$((_last + INTERVAL_DAYS)) ;;
    *)       _sched=$_today ;;
  esac
  [ "$_last" -ge "$_sched" ] && return 1
  [ "$_today" -gt "$_sched" ] && return 0
  [ "$_today" -eq "$_sched" ] && [ "$_h" -ge "$RUN_HOUR" ]
}

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
  _fg=$(foreground_pkg)   # a cleanup skips the on-screen app, so don't count it here either
  du -sk $CACHE_GLOBS 2>/dev/null | {
    t=0
    while read -r s p; do
      [ "$s" -gt 4 ] 2>/dev/null || continue
      pkg=${p%/cache}; pkg=${pkg%/code_cache}; pkg=${pkg##*/}
      is_excluded "$pkg" && continue
      [ -n "$_fg" ] && [ "$pkg" = "$_fg" ] && continue
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

# Package currently in the foreground (empty if none / screen off)
foreground_pkg() {
  dumpsys activity activities 2>/dev/null | grep -E 'topResumedActivity|mResumedActivity' | head -n 1 \
    | sed -n 's/.* u[0-9]* \([A-Za-z0-9_.]*\)\/.*/\1/p'
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
