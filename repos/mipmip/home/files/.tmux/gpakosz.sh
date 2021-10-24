# exit the script if any statement returns a non-true return value
set -e

unset GREP_OPTIONS
export LC_NUMERIC=C

if ! printf '' | sed -E 's///' 2>/dev/null; then
  if printf '' | sed -r 's///' 2>/dev/null; then
    sed () {
      n=$#; while [ "$n" -gt 0 ]; do arg=$1; shift; case $arg in -E*) arg=-r${arg#-E};; esac; set -- "$@" "$arg"; n=$(( n - 1 )); done
      command sed "$@"
    }
  fi
fi

__newline='
'

_is_enabled() {
  ( ([ x"$1" = x"enabled" ] || [ x"$1" = x"true" ] || [ x"$1" = x"yes" ] || [ x"$1" = x"1" ]) && return 0 ) || return 1
}

_circled() {
  circled_digits='⓪ ① ② ③ ④ ⑤ ⑥ ⑦ ⑧ ⑨ ⑩ ⑪ ⑫ ⑬ ⑭ ⑮ ⑯ ⑰ ⑱ ⑲ ⑳'
  if [ "$1" -le 20 ] 2>/dev/null; then
    i=$(( $1 + 1 ))
    eval set -- "$circled_digits"
    eval echo "\${$i}"
  else
    echo "$1"
  fi
}

_decode_unicode_escapes() {
  printf '%s' "$*" | perl -CS -pe 's/(\\u([0-9A-Fa-f]{1,4})|\\U([0-9A-Fa-f]{1,8}))/chr(hex($2.$3))/eg' 2>/dev/null
}

_maximize_pane() {
  current_session=${1:-$(tmux display -p '#{session_name}')}
  current_pane=${2:-$(tmux display -p '#{pane_id}')}

  dead_panes=$(tmux list-panes -s -t "$current_session" -F '#{pane_dead} #{pane_id} #{pane_start_command}' | grep -E -o '^1 %.+maximized.+$' || true)
  restore=$(echo "$dead_panes" | sed -n -E -e "s/^1 $current_pane .+maximized.+'(%[0-9]+)'$/tmux swap-pane -s \1 -t $current_pane \; kill-pane -t $current_pane/p" -e "s/^1 (%[0-9]+) .+maximized.+'$current_pane'$/tmux swap-pane -s \1 -t $current_pane \; kill-pane -t \1/p" )

  if [ -z "$restore" ]; then
    [ "$(tmux list-panes -t "$current_session:" | wc -l | sed 's/^ *//g')" -eq 1 ] && tmux display "Can't maximize with only one pane" && return
    window=$(tmux new-window -t "$current_session:" -P "exec maximized... 2> /dev/null & tmux setw -t \"$current_session:\" remain-on-exit on; printf \"Pane has been maximized, press <prefix>+ to restore. %s\" '$current_pane'")
    window=${window%.*}

    retry=10
    while [ x"$(tmux list-panes -t "$window" -F '#{session_name}:#{window_index} #{pane_dead}' 2>/dev/null)" != x"$window 1" ] && [ "$retry" -ne 0 ]; do
      sleep 0.05
      retry=$((retry - 1))
    done
    if [ "$retry" -eq 0 ]; then
      tmux display 'Unable to maximize pane'
    fi

    new_pane=$(tmux display -t "$window" -p '#{pane_id}')
    tmux setw -t "$window" remain-on-exit off \; swap-pane -s "$current_pane" -t "$new_pane"
  else
    $restore || tmux kill-pane
  fi
}

_toggle_mouse() {
  old=$(tmux show -gv mouse)
  new=""

  if [ "$old" = "on" ]; then
    new="off"
  else
    new="on"
  fi

  tmux set -g mouse $new \;\
       display "mouse: $new"
}

_battery() {
  count=0
  charge=0
  uname_s=$(uname -s)
  case "$uname_s" in
    *Darwin*)
      while IFS= read -r line; do
        if [ x"$discharging" != x"true" ]; then
          discharging=$(printf '%s' "$line" | grep -qi "discharging" && echo "true" || echo "false")
        fi
        percentage=$(printf '%s' "$line" | grep -E -o '[0-9]+%')
        charge=$(awk -v charge="$charge" -v percentage="${percentage%%%}" 'BEGIN { print charge + percentage / 100 }')
        count=$((count + 1))
      done  << EOF
$(pmset -g batt | grep 'InternalBattery')
EOF
      ;;
    *Linux*)
      while IFS= read -r batpath; do
        grep -i -q device "$batpath/scope" 2> /dev/null && continue

        if [ x"$discharging" != x"true" ]; then
          discharging=$(grep -qi "discharging" "$batpath/status" && echo "true" || echo "false")
        fi
        bat_capacity="$batpath/capacity"
        if [ -r "$bat_capacity" ]; then
          charge=$(awk -v charge="$charge" -v capacity="$(cat "$bat_capacity")" 'BEGIN { print charge + capacity / 100 }')
        else
          bat_energy_full="$batpath/energy_full"
          bat_energy_now="$batpath/energy_now"
          if [ -r "$bat_energy_full" ] && [ -r "$bat_energy_now" ]; then
            charge=$(awk -v charge="$charge" -v energy_now="$(cat "$bat_energy_now")" -v energy_full="$(cat "$bat_energy_full")" 'BEGIN { print charge + energy_now / energy_full }')
          fi
        fi
        count=$((count + 1))
      done  << EOF
$(find /sys/class/power_supply -maxdepth 1 -iname '*bat*')
EOF
      ;;
    *CYGWIN*|*MSYS*|*MINGW*)
      while IFS= read -r line; do
        count=$((count + 1))
      done  << EOF
$(wmic path Win32_Battery get BatteryStatus, EstimatedChargeRemaining | tr -d '\r' | tail -n +2)
EOF
      ;;
    *OpenBSD*)
      for batid in 0 1 2; do
        sysctl -n "hw.sensors.acpibat$batid.raw0" 2>&1 | grep -q 'not found' && continue
        if [ x"$discharging" != x"true" ]; then
          discharging=$(sysctl -n "hw.sensors.acpibat$batid.raw0" | grep -q 1 && echo "true" || echo "false")
        fi
        if sysctl -n "hw.sensors.acpibat$batid" | grep -q amphour; then
          charge=$(awk -v charge="$charge" -v remaining="$(sysctl -n hw.sensors.acpibat$batid.amphour3 | cut -d' ' -f1)" -v full="$(sysctl -n hw.sensors.acpibat$batid.amphour0 | cut -d' ' -f1)" 'BEGIN { print charge + remaining / full }')
        else
          charge=$(awk -v charge="$charge" -v remaining="$(sysctl -n hw.sensors.acpibat$batid.watthour3 | cut -d' ' -f1)" -v full="$(sysctl -n hw.sensors.acpibat$batid.watthour0 | cut -d' ' -f1)" 'BEGIN { print charge + remaining / full }')
        fi
        count=$((count + 1))
      done
      ;;
  esac
  [ "$count" -ne 0 ] && charge=$(awk -v charge="$charge" -v count="$count" 'BEGIN { print charge / count }')
  if [ "$charge" -eq 0 ]; then
    tmux  set -ug '@battery_status'  \;\
          set -ug '@battery_bar'     \;\
          set -ug '@battery_hbar'    \;\
          set -ug '@battery_vbar'    \;\
          set -ug '@battery_percentage'
    return
  fi

  variables=$(tmux  show -gqv '@battery_bar_symbol_full' \;\
                    show -gqv '@battery_bar_symbol_empty' \;\
                    show -gqv '@battery_bar_length' \;\
                    show -gqv '@battery_bar_palette' \;\
                    show -gqv '@battery_hbar_palette' \;\
                    show -gqv '@battery_vbar_palette' \;\
                    show -gqv '@battery_status_charging' \;\
                    show -gqv '@battery_status_discharging')
  # shellcheck disable=SC2086
  { set -f; IFS="$__newline"; set -- $variables; unset IFS; set +f; }

  battery_bar_symbol_full=$1
  battery_bar_symbol_empty=$2
  battery_bar_length=$3
  battery_bar_palette=$4
  battery_hbar_palette=$5
  battery_vbar_palette=$6
  battery_status_charging=$7
  battery_status_discharging=$8

  if [ x"$battery_bar_length" = x"auto" ]; then
    columns=$(tmux -q display -p '#{client_width}' 2> /dev/null || echo 80)
    if [ "$columns" -ge 80 ]; then
      battery_bar_length=10
    else
      battery_bar_length=5
    fi
  fi

  if [ x"$discharging" = x"true" ]; then
    battery_status="$battery_status_discharging"
  else
    battery_status="$battery_status_charging"
  fi

  if echo "$battery_bar_palette" | grep -q -E '^heat|gradient(,[#a-z0-9]{7,9})?$'; then
    # shellcheck disable=SC2086
    { set -f; IFS=,; set -- $battery_bar_palette; unset IFS; set +f; }
    palette_style=$1
    battery_bg=${2:-none}
    [ x"$palette_style" = x"gradient" ] && \
      palette="196 202 208 214 220 226 190 154 118 82 46"
    [ x"$palette_style" = x"heat" ] && \
      palette="243 245 247 144 143 142 184 214 208 202 196"

    palette=$(echo "$palette" | awk -v n="$battery_bar_length" '{ for (i = 0; i < n; ++i) printf $(1 + (i * NF / n))" " }')
    eval set -- "$palette"

    full=$(awk "BEGIN { printf \"%.0f\", ($charge) * $battery_bar_length }")
    battery_bar="#[bg=$battery_bg]"
    # shellcheck disable=SC2046
    [ "$full" -gt 0 ] && \
      battery_bar="$battery_bar$(printf "#[fg=colour%s]$battery_bar_symbol_full" $(echo "$palette" | cut -d' ' -f1-"$full"))"
    # shellcheck disable=SC2046
    empty=$((battery_bar_length - full))
    # shellcheck disable=SC2046
    [ "$empty" -gt 0 ] && \
      battery_bar="$battery_bar$(printf "#[fg=colour%s]$battery_bar_symbol_empty" $(echo "$palette" | cut -d' ' -f$((full + 1))-$((full + empty))))"
      eval battery_bar="$battery_bar#[fg=colour\${$((full == 0 ? 1 : full))}]"
  elif echo "$battery_bar_palette" | grep -q -E '^(([#a-z0-9]{7,9}|none),?){3}$'; then
    # shellcheck disable=SC2086
    { set -f; IFS=,; set -- $battery_bar_palette; unset IFS; set +f; }
    battery_full_fg=$1
    battery_empty_fg=$2
    battery_bg=$3

    full=$(awk "BEGIN { printf \"%.0f\", ($charge) * $battery_bar_length }")
    [ x"$battery_bg" != x"none" ] && \
      battery_bar="#[bg=$battery_bg]"
    #shellcheck disable=SC2046
    [ "$full" -gt 0 ] && \
      battery_bar="$battery_bar#[fg=$battery_full_fg]$(printf "%0.s$battery_bar_symbol_full" $(seq 1 "$full"))"
    empty=$((battery_bar_length - full))
    #shellcheck disable=SC2046
    [ "$empty" -gt 0 ] && \
      battery_bar="$battery_bar#[fg=$battery_empty_fg]$(printf "%0.s$battery_bar_symbol_empty" $(seq 1 "$empty"))" && \
      battery_bar="$battery_bar#[fg=$battery_empty_fg]"
  fi

  if echo "$battery_hbar_palette" | grep -q -E '^heat|gradient(,[#a-z0-9]{7,9})?$'; then
    # shellcheck disable=SC2086
    { set -f; IFS=,; set -- $battery_hbar_palette; unset IFS; set +f; }
    palette_style=$1
    [ x"$palette_style" = x"gradient" ] && \
      palette="196 202 208 214 220 226 190 154 118 82 46"
    [ x"$palette_style" = x"heat" ] && \
      palette="233 234 235 237 239 241 243 245 247 144 143 142 184 214 208 202 196"

    palette=$(echo "$palette" | awk -v n="$battery_bar_length" '{ for (i = 0; i < n; ++i) printf $(1 + (i * NF / n))" " }')
    eval set -- "$palette"

    full=$(awk "BEGIN { printf \"%.0f\", ($charge) * $battery_bar_length }")
    eval battery_hbar_fg="colour\${$((full == 0 ? 1 : full))}"
  elif echo "$battery_hbar_palette" | grep -q -E '^([#a-z0-9]{7,9},?){3}$'; then
    # shellcheck disable=SC2086
    { set -f; IFS=,; set -- $battery_hbar_palette; unset IFS; set +f; }

    # shellcheck disable=SC2046
    eval $(awk "BEGIN { printf \"battery_hbar_fg=$%d\", (($charge) - 0.001) * $# + 1 }")
  fi

  eval set -- "▏ ▎ ▍ ▌ ▋ ▊ ▉ █"
  # shellcheck disable=SC2046
  eval $(awk "BEGIN { printf \"battery_hbar_symbol=$%d\", ($charge) * ($# - 1) + 1 }")
  battery_hbar="#[fg=${battery_hbar_fg?}]${battery_hbar_symbol?}"

  if echo "$battery_vbar_palette" | grep -q -E '^heat|gradient(,[#a-z0-9]{7,9})?$'; then
    # shellcheck disable=SC2086
    { set -f; IFS=,; set -- $battery_vbar_palette; unset IFS; set +f; }
    palette_style=$1
    [ x"$palette_style" = x"gradient" ] && \
      palette="196 202 208 214 220 226 190 154 118 82 46"
    [ x"$palette_style" = x"heat" ] && \
      palette="233 234 235 237 239 241 243 245 247 144 143 142 184 214 208 202 196"

    palette=$(echo "$palette" | awk -v n="$battery_bar_length" '{ for (i = 0; i < n; ++i) printf $(1 + (i * NF / n))" " }')
    eval set -- "$palette"

    full=$(awk "BEGIN { printf \"%.0f\", ($charge) * $battery_bar_length }")
    eval battery_vbar_fg="colour\${$((full == 0 ? 1 : full))}"
  elif echo "$battery_vbar_palette" | grep -q -E '^([#a-z0-9]{7,9},?){3}$'; then
    # shellcheck disable=SC2086
    { set -f; IFS=,; set -- $battery_vbar_palette; unset IFS; set +f; }

    # shellcheck disable=SC2046
    eval $(awk "BEGIN { printf \"battery_vbar_fg=$%d\", (($charge) - 0.001) * $# + 1 }")
  fi

  eval set -- "▁ ▂ ▃ ▄ ▅ ▆ ▇ █"
  # shellcheck disable=SC2046
  eval $(awk "BEGIN { printf \"battery_vbar_symbol=$%d\", ($charge) * ($# - 1) + 1 }")
  battery_vbar="#[fg=${battery_vbar_fg?}]${battery_vbar_symbol?}"

  battery_percentage="$(awk "BEGIN { printf \"%.0f%%\", ($charge) * 100 }")"

  tmux  set -g '@battery_status' "$battery_status" \;\
        set -g '@battery_bar' "$battery_bar" \;\
        set -g '@battery_hbar' "$battery_hbar" \;\
        set -g '@battery_vbar' "$battery_vbar" \;\
        set -g '@battery_percentage' "$battery_percentage"
}

_tty_info() {
  tty="${1##/dev/}"
  uname -s | grep -q "CYGWIN" && cygwin=true

  if [ x"$cygwin" = x"true" ]; then
    ps -af | tail -n +2 | awk -v tty="$tty" '
      ((/ssh/ && !/-W/) || !/ssh/) && $4 == tty {
        user[$2] = $1; parent[$2] = $3; child[$3] = $2
      }
      END {
        for (i in user)
        {
          if (!(i in child) && parent[i] != 1)
          {
            file = "/proc/" i "/cmdline"; getline command < file; close(file)
            gsub(/\0/, " ", command)
            print i, user[i], command
            exit
          }
        }
      }
    '
  else
    ps -t "$tty" -o user=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX -o pid= -o ppid= -o command= | awk '
      NR > 1 && ((/ssh/ && !/-W/) || !/ssh/) {
        user[$2] = $1; parent[$2] = $3; child[$3] = $2; for (i = 4 ; i <= NF; ++i) command[$2] = i > 4 ? command[$2] FS $i : $i
      }
      END {
        for (i in parent)
        {
          if (!(i in child) && parent[i] != 1)
          {
            print i, user[i], command[i]
            exit
          }
        }
      }
    '
  fi
}

_ssh_or_mosh_args() {
  args=$(printf '%s' "$1" | awk '/ssh/ && !/vagrant ssh/ && !/autossh/ && !/-W/ { $1=""; print $0; exit }')
  if [ -z "$args" ]; then
    args=$(printf '%s' "$1" | grep 'mosh-client' | sed -E -e 's/.*mosh-client -# (.*)\|.*$/\1/' -e 's/-[^ ]*//g' -e 's/\d:\d//g')
  fi

 printf '%s' "$args"
}

_username() {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  ssh_only=$2

  tty_info=$(_tty_info "$tty")
  command=$(printf '%s' "$tty_info" | cut -d' ' -f3-)

  ssh_or_mosh_args=$(_ssh_or_mosh_args "$command")
  if [ -n "$ssh_or_mosh_args" ]; then
    # shellcheck disable=SC2086
    username=$(ssh -G $ssh_or_mosh_args 2>/dev/null | awk 'NR > 2 { exit } ; /^user / { print $2 }')
    # shellcheck disable=SC2086
    [ -z "$username" ] && username=$(ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%username%% %r >&2'" $ssh_or_mosh_args 2>&1 | awk '/^%username% / { print $2; exit }')
  else
    if ! _is_enabled "$ssh_only"; then
      username=$(printf '%s' "$tty_info" | cut -d' ' -f2)
    fi
  fi

  printf '%s' "$username"
}

_hostname() {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  ssh_only=$2

  tty_info=$(_tty_info "$tty")
  command=$(printf '%s' "$tty_info" | cut -d' ' -f3-)

  ssh_or_mosh_args=$(_ssh_or_mosh_args "$command")
  if [ -n "$ssh_or_mosh_args" ]; then
    # shellcheck disable=SC2086
    hostname=$(ssh -G $ssh_or_mosh_args 2>/dev/null | awk 'NR > 2 { exit } ; /^hostname / { print $2 }')
    # shellcheck disable=SC2086
    [ -z "$hostname" ] && hostname=$(ssh -T -o ControlPath=none -o ProxyCommand="sh -c 'echo %%hostname%% %h >&2'" $ssh_or_mosh_args 2>&1 | awk '/^%hostname% / { print $2; exit }')
    #shellcheck disable=SC1004
    hostname=$(echo "$hostname" | awk '\
    { \
      if ($1~/^[0-9.:]+$/) \
        print $1; \
      else \
        split($1, a, ".") ; print a[1] \
    }')
  else
    if ! _is_enabled "$ssh_only"; then
      hostname=$(command hostname -s)
    fi
  fi

  printf '%s' "$hostname"
}

_root() {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  username=$(_username "$tty" false)

  if [ x"$username" = x"root" ]; then
    tmux show -gqv '@root'
  else
    echo ""
  fi
}

_uptime() {
  case $(uname -s) in
    *Darwin*)
      boot=$(sysctl -q -n kern.boottime | awk -F'[ ,:]+' '{ print $4 }')
      now=$(date +%s)
      ;;
    *Linux*|*CYGWIN*|*MSYS*|*MINGW*)
      boot=0
      now=$(cut -d' ' -f1 < /proc/uptime)
      ;;
    *OpenBSD*)
      boot=$(sysctl -n kern.boottime)
      now=$(date +%s)
  esac
  # shellcheck disable=SC1004
  awk -v boot="$boot" -v now="$now" '
    BEGIN {
      uptime = now - boot
      y = int(uptime / 31536000)
      dy = int(uptime / 86400) % 365
      d = int(uptime / 86400)
      h = int(uptime / 3600) % 24
      m = int(uptime / 60) % 60
      s = int(uptime) % 60

      system("tmux  set -g @uptime_y " y + 0 " \\; " \
                   "set -g @uptime_dy " dy + 0 " \\; " \
                   "set -g @uptime_d " d + 0 " \\; " \
                   "set -g @uptime_h " h + 0 " \\; " \
                   "set -g @uptime_m " m + 0 " \\; " \
                   "set -g @uptime_s " s + 0)
    }'
}

_loadavg() {
  case $(uname -s) in
    *Darwin*)
      tmux set -g @loadavg "$(sysctl -q -n vm.loadavg | cut -d' ' -f2)"
      ;;
    *Linux*)
      tmux set -g @loadavg "$(cut -d' ' -f1 < /proc/loadavg)"
      ;;
    *OpenBSD*)
      tmux set -g @loadavg "$(sysctl -q -n vm.loadavg | cut -d' ' -f1)"
      ;;
  esac
}

_split_window() {
  tty=${1:-$(tmux display -p '#{pane_tty}')}
  shift

  tty_info=$(_tty_info "$tty")
  command=$(printf '%s' "$tty_info" | cut -d' ' -f3-)

  case "$command" in
    *mosh-client*)
      # shellcheck disable=SC2046
       tmux split-window "$@" mosh $(echo "$command" | sed -E -e 's/.*mosh-client -# (.*)\|.*$/\1/')
     ;;
    *ssh*)
      # shellcheck disable=SC2046
      tmux split-window "$@" $(echo "$command" | sed -e 's/;/\\;/g')
      ;;
    *)
      tmux split-window "$@"
  esac
}

_apply_overrides() {
  tmux_conf_theme_24b_colour=${tmux_conf_theme_24b_colour:-false}
  if _is_enabled "$tmux_conf_theme_24b_colour"; then
  case "$TERM" in
    screen-*|tmux-*)
      ;;
    *)
      tmux set-option -ga terminal-overrides ",*256col*:Tc"
      ;;
  esac
  fi
}

_apply_bindings() {
  #cfg=$(mktemp) && trap 'rm -f $cfg*' EXIT
  cfg=/tmp/tmux.conf

  tmux list-keys | grep -vF 'tmux.conf.local' | grep -E '(new-window|split(-|_)window|new-session|copy-selection|copy-pipe)' > "$cfg"

  # tmux 3.0 doesn't include 02254d1e5c881be95fd2fc37b4c4209640b6b266 and the
  # output of list-keys can be truncated
  perl -p -i -e "s/'#\{\?window_zoomed_flag,Unzoom,Zoom\}' 'z' \{resize-pane -$/'#{?window_zoomed_flag,Unzoom,Zoom}' 'z' {resize-pane -Z}\"/g" "$cfg"

  tmux_conf_new_window_retain_current_path=${tmux_conf_new_window_retain_current_path:-false}
  if _is_enabled "$tmux_conf_new_window_retain_current_path"; then
    perl -p -i \
      -e "s/\b(new-window)\b(?!\s+-)/{$&}/g if /\bdisplay-menu\b/" \
      -e ';' \
      -e "s/\bnew-window\b(?!([^;}\n\"]*?)(?:\s+-c\s+(\\\?\"?|'?)#\{pane_current_path\}\2))/new-window -c '#{pane_current_path}'/g" \
      "$cfg"
  else
    perl -p -i -e "s/\bnew-window\b([^;}\n\"]*?)(?:\s+-c\s+(\\\?\"?|'?)#\{pane_current_path\}\2)/new-window\1/g" "$cfg"
  fi

  tmux_conf_new_pane_retain_current_path=${tmux_conf_new_pane_retain_current_path:-false}
  if _is_enabled "$tmux_conf_new_pane_retain_current_path"; then
    perl -p -i -e "s/\bsplit-window\b(?!([^;}\n\"]*?)(?:\s+-c\s+(\\\?\"?|'?)#\{pane_current_path\}\2))/split-window -c '#{pane_current_path}'/g" "$cfg"
  else
    perl -p -i -e "s/\bsplit-window\b([^;}\n\"]*?)(?:\s+-c\s+(\\\?\"?|'?)#\{pane_current_path\}\2)/split-window\1/g" "$cfg"
  fi

  tmux_conf_new_pane_reconnect_ssh=${tmux_conf_new_pane_reconnect_ssh:-false}
  if _is_enabled "$tmux_conf_new_pane_reconnect_ssh"; then
    if _is_enabled "$tmux_conf_new_pane_retain_current_path"; then
      perl -p -i \
        -e "s/\bsplit-window\b([^;}\n\"]*?)(?:\s+-c\s+(\\\?\"?|'?)#\{pane_current_path\}\2)([^;}\n\"]*)/run-shell 'cut -c3- ~\/\.tmux\.conf | sh -s _split_window #{pane_tty}\1\3 -c #\{pane_current_path\}'/g" \
        -e ';' \
        -e "s/\b_split_window\b\s+#\{pane_tty\}(.*?)\s+-c\s+\\\\\"#\{pane_current_path\}\\\\\"\"/_split_window #{pane_tty}\1 -c \\\\\"#{pane_current_path}\\\\\"\"/g" \
        "$cfg"
    else
      perl -p -i \
        -e "s/\bsplit-window\b([^;}\n]*)/run-shell 'cut -c3- ~\/\.tmux\.conf | sh -s _split_window #{pane_tty}\1'/g" \
        -e ';' \
        -e "s/\b_split_window\b\s+#\{pane_tty\}(.*?)\s+-c\s+\\\\\"#\{pane_current_path\}\\\\\"\"/_split_window #{pane_tty}\1\"/g" \
        "$cfg"
    fi
  else
    if _is_enabled "$tmux_conf_new_pane_retain_current_path"; then
      perl -p -i -e "s/\brun-shell\b(\s+(\"|')cut\s+-c3-\s+~\/\.tmux\.conf\s+\|\s+sh\s+-s\s+_split_window\s+#\{pane_tty\})(.*?)\s+-c\s+#\{pane_current_path\}\2/split-window\3 -c '#{pane_current_path}'/g" "$cfg"
    else
      perl -p -i -e "s/\brun-shell\b(\s+(\"|')cut\s+-c3-\s+~\/\.tmux\.conf\s+\|\s+sh\s+-s\s+_split_window\s+#\{pane_tty\})(.*)\2/split-window\3/g" "$cfg"
    fi
  fi

  tmux_conf_new_session_prompt=${tmux_conf_new_session_prompt:-false}
  if _is_enabled "$tmux_conf_new_session_prompt"; then
    perl -p -i \
      -e "s/(?<!command-prompt -p )\b(new-session)\b(?!\s+-)/{$&}/g if /\bdisplay-menu\b/" \
      -e ';' \
      -e "s/(?<!\bcommand-prompt -p )\bnew-session\b(?! -s)/command-prompt -p new-session 'new-session -s \"%%\"'/g" \
      "$cfg"
  else
    perl -p -i -e "s/\bcommand-prompt\s+-p\s+new-session\s+'new-session\s+-s\s+\"%%\"'/new-session/g" "$cfg"
  fi

  tmux_conf_copy_to_os_clipboard=${tmux_conf_copy_to_os_clipboard:-false}
  command -v pbcopy > /dev/null 2>&1 && command='pbcopy'
  command -v reattach-to-user-namespace > /dev/null 2>&1 && command='reattach-to-user-namespace pbcopy'
  command -v xsel > /dev/null 2>&1 && command='xsel -i -b'
  ! command -v xsel > /dev/null 2>&1 && command -v xclip > /dev/null 2>&1 && command='xclip -i -selection clipboard > \/dev\/null 2>\&1'
  command -v clip.exe > /dev/null 2>&1 && command='clip\.exe'
  [ -c /dev/clipboard ] && command='cat > \/dev\/clipboard'

  if [ -n "$command" ]; then
    if _is_enabled "$tmux_conf_copy_to_os_clipboard"; then
      perl -p -i -e "s/\bcopy-selection(-and-cancel)?\b/copy-pipe\1 '$command'/g" "$cfg"
    else
      perl -p -i -e "s/\bcopy-pipe(-and-cancel)?\b\s+(\"|')?$command\2/copy-selection\1/g" "$cfg"
    fi
  fi

  # until tmux >= 3.0, output of tmux list-keys can't be consumed back by tmux source-file without applying some escapings
  awk < "$cfg" \
    '{i = $2 == "-T" ? 4 : 5; gsub(/^[;]$/, "\\\\&", $i); gsub(/^[$"#~]$/, "'"'"'&'"'"'", $i); gsub(/^['"'"']$/, "\"&\"", $i); print}' > "$cfg.in"

  # ignore bindings with errors
  while ! out=$(tmux source-file "$cfg.in"); do
    line=$(printf "%s" "$out" | cut -d':' -f2)
    perl -n -i -e "if ($. != $line) { print }" "$cfg.in"
  done
}

_apply_theme() {

  # -- panes -------------------------------------------------------------

  tmux_conf_theme_window_fg=${tmux_conf_theme_window_fg:-default}
  tmux_conf_theme_window_bg=${tmux_conf_theme_window_bg:-default}
  tmux_conf_theme_highlight_focused_pane=${tmux_conf_theme_highlight_focused_pane:-false}
  tmux_conf_theme_focused_pane_fg=${tmux_conf_theme_focused_pane_fg:-'default'} # default
  tmux_conf_theme_focused_pane_bg=${tmux_conf_theme_focused_pane_bg:-'#0087d7'} # light blue

  # tmux 1.9 doesn't really like set -q
  if tmux show -g -w | grep -q window-style; then
    tmux setw -g window-style "fg=$tmux_conf_theme_window_fg,bg=$tmux_conf_theme_window_bg"

    if _is_enabled "$tmux_conf_theme_highlight_focused_pane"; then
      tmux setw -g window-active-style "fg=$tmux_conf_theme_focused_pane_fg,bg=$tmux_conf_theme_focused_pane_bg"
    else
      tmux setw -g window-active-style default
    fi
  fi

  tmux_conf_theme_pane_border_style=${tmux_conf_theme_pane_border_style:-thin}
  tmux_conf_theme_pane_border=${tmux_conf_theme_pane_border:-'#444444'}               # light gray
  tmux_conf_theme_pane_active_border=${tmux_conf_theme_pane_active_border:-'#00afff'} # light blue
  tmux_conf_theme_pane_border_fg=${tmux_conf_theme_pane_border_fg:-$tmux_conf_theme_pane_border}
  tmux_conf_theme_pane_active_border_fg=${tmux_conf_theme_pane_active_border_fg:-$tmux_conf_theme_pane_active_border}
  case "$tmux_conf_theme_pane_border_style" in
    fat)
      tmux_conf_theme_pane_border_bg=${tmux_conf_theme_pane_border_bg:-$tmux_conf_theme_pane_border_fg}
      tmux_conf_theme_pane_active_border_bg=${tmux_conf_theme_pane_active_border_bg:-$tmux_conf_theme_pane_active_border_fg}
      ;;
    thin|*)
      tmux_conf_theme_pane_border_bg=${tmux_conf_theme_pane_border_bg:-'default'}
      tmux_conf_theme_pane_active_border_bg=${tmux_conf_theme_pane_active_border_bg:-'default'}
      ;;
  esac
  tmux setw -g pane-border-style "fg=$tmux_conf_theme_pane_border_fg,bg=$tmux_conf_theme_pane_border_bg" \; set -g pane-active-border-style "fg=$tmux_conf_theme_pane_active_border_fg,bg=$tmux_conf_theme_pane_active_border_bg"

  tmux_conf_theme_pane_indicator=${tmux_conf_theme_pane_indicator:-'#00afff'}               # light blue
  tmux_conf_theme_pane_active_indicator=${tmux_conf_theme_pane_active_indicator:-'#00afff'} # light blue

  tmux set -g display-panes-colour "$tmux_conf_theme_pane_indicator" \; set -g display-panes-active-colour "$tmux_conf_theme_pane_active_indicator"

  # -- status line -------------------------------------------------------

  tmux_conf_theme_left_separator_main=$(_decode_unicode_escapes "${tmux_conf_theme_left_separator_main-}")
  tmux_conf_theme_left_separator_sub=$(_decode_unicode_escapes "${tmux_conf_theme_left_separator_sub-|}")
  tmux_conf_theme_right_separator_main=$(_decode_unicode_escapes "${tmux_conf_theme_right_separator_main-}")
  tmux_conf_theme_right_separator_sub=$(_decode_unicode_escapes "${tmux_conf_theme_right_separator_sub-|}")

  tmux_conf_theme_message_fg=${tmux_conf_theme_message_fg:-'#000000'}   # black
  tmux_conf_theme_message_bg=${tmux_conf_theme_message_bg:-'#ffff00'}   # yellow
  tmux_conf_theme_message_attr=${tmux_conf_theme_message_attr:-'bold'}
  tmux set -g message-style "fg=$tmux_conf_theme_message_fg,bg=$tmux_conf_theme_message_bg,$tmux_conf_theme_message_attr"

  tmux_conf_theme_message_command_fg=${tmux_conf_theme_message_command_fg:-'#ffff00'} # yellow
  tmux_conf_theme_message_command_bg=${tmux_conf_theme_message_command_bg:-'#000000'} # black
  tmux_conf_theme_message_command_attr=${tmux_conf_theme_message_command_attr:-'bold'}
  tmux set -g message-command-style "fg=$tmux_conf_theme_message_command_fg,bg=$tmux_conf_theme_message_command_bg,$tmux_conf_theme_message_command_attr"

  tmux_conf_theme_mode_fg=${tmux_conf_theme_mode_fg:-'#000000'} # black
  tmux_conf_theme_mode_bg=${tmux_conf_theme_mode_bg:-'#ffff00'} # yellow
  tmux_conf_theme_mode_attr=${tmux_conf_theme_mode_attr:-'bold'}
  tmux setw -g mode-style "fg=$tmux_conf_theme_mode_fg,bg=$tmux_conf_theme_mode_bg,$tmux_conf_theme_mode_attr"

  tmux_conf_theme_status_fg=${tmux_conf_theme_status_fg:-'#8a8a8a'} # white
  tmux_conf_theme_status_bg=${tmux_conf_theme_status_bg:-'#080808'} # dark gray
  tmux_conf_theme_status_attr=${tmux_conf_theme_status_attr:-'none'}
  tmux  set -g status-style "fg=$tmux_conf_theme_status_fg,bg=$tmux_conf_theme_status_bg,$tmux_conf_theme_status_attr"        \;\
        set -g status-left-style "fg=$tmux_conf_theme_status_fg,bg=$tmux_conf_theme_status_bg,$tmux_conf_theme_status_attr"   \;\
        set -g status-right-style "fg=$tmux_conf_theme_status_fg,bg=$tmux_conf_theme_status_bg,$tmux_conf_theme_status_attr"

  tmux_conf_theme_terminal_title=${tmux_conf_theme_terminal_title:-'#h ❐ #S ● #I #W'}

  tmux_conf_theme_terminal_title=$(echo "$tmux_conf_theme_terminal_title" | sed \
    -e 's%#{circled_window_index}%#(cut -c3- ~/.tmux.conf | sh -s _circled #I)%g' \
    -e 's%#{circled_session_name}%#(cut -c3- ~/.tmux.conf | sh -s _circled #S)%g' \
    -e 's%#{username}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} false #D)%g' \
    -e 's%#{hostname}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} false #D)%g' \
    -e 's%#{username_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} true #D)%g' \
    -e 's%#{hostname_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} true #D)%g')
  tmux set -g set-titles-string "$(_decode_unicode_escapes "$tmux_conf_theme_terminal_title")"

  tmux_conf_theme_window_status_fg=${tmux_conf_theme_window_status_fg:-'#8a8a8a'} # white
  tmux_conf_theme_window_status_bg=${tmux_conf_theme_window_status_bg:-'#080808'} # dark gray
  tmux_conf_theme_window_status_attr=${tmux_conf_theme_window_status_attr:-'none'}
  tmux_conf_theme_window_status_format=${tmux_conf_theme_window_status_format:-'#I #W'}

  tmux_conf_theme_window_status_current_fg=${tmux_conf_theme_window_status_current_fg:-'#000000'} # black
  tmux_conf_theme_window_status_current_bg=${tmux_conf_theme_window_status_current_bg:-'#00afff'} # light blue
  tmux_conf_theme_window_status_current_attr=${tmux_conf_theme_window_status_current_attr:-'bold'}
  tmux_conf_theme_window_status_current_format=${tmux_conf_theme_window_status_current_format:-'#I #W'}
  if [ x"$(tmux show -g -v status-justify)" = x"right" ]; then
    tmux_conf_theme_window_status_current_format="#[fg=$tmux_conf_theme_window_status_current_bg,bg=$tmux_conf_theme_window_status_bg]$tmux_conf_theme_right_separator_main#[fg=$tmux_conf_theme_window_status_current_fg,bg=$tmux_conf_theme_window_status_current_bg,$tmux_conf_theme_window_status_current_attr] $tmux_conf_theme_window_status_current_format #[fg=$tmux_conf_theme_window_status_bg,bg=$tmux_conf_theme_window_status_current_bg,none]$tmux_conf_theme_right_separator_main"
  else
    tmux_conf_theme_window_status_current_format="#[fg=$tmux_conf_theme_window_status_bg,bg=$tmux_conf_theme_window_status_current_bg]$tmux_conf_theme_left_separator_main#[fg=$tmux_conf_theme_window_status_current_fg,bg=$tmux_conf_theme_window_status_current_bg,$tmux_conf_theme_window_status_current_attr] $tmux_conf_theme_window_status_current_format #[fg=$tmux_conf_theme_window_status_current_bg,bg=$tmux_conf_theme_status_bg,none]$tmux_conf_theme_left_separator_main"
  fi

  tmux_conf_theme_window_status_format=$(echo "$tmux_conf_theme_window_status_format" | sed \
    -e 's%#{circled_window_index}%#(cut -c3- ~/.tmux.conf | sh -s _circled #I)%g' \
    -e 's%#{circled_session_name}%#(cut -c3- ~/.tmux.conf | sh -s _circled #S)%g' \
    -e 's%#{username}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} false #D)%g' \
    -e 's%#{hostname}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} false #D)%g' \
    -e 's%#{username_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} true #D)%g' \
    -e 's%#{hostname_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} true #D)%g')
  tmux_conf_theme_window_status_current_format=$(echo "$tmux_conf_theme_window_status_current_format" | sed \
    -e 's%#{circled_window_index}%#(cut -c3- ~/.tmux.conf | sh -s _circled #I)%g' \
    -e 's%#{circled_session_name}%#(cut -c3- ~/.tmux.conf | sh -s _circled #S)%g' \
    -e 's%#{username}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} false #D)%g' \
    -e 's%#{hostname}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} false #D)%g' \
    -e 's%#{username_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} true #D)%g' \
    -e 's%#{hostname_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} true #D)%g')

  tmux  setw -g window-status-style "fg=$tmux_conf_theme_window_status_fg,bg=$tmux_conf_theme_window_status_bg,$tmux_conf_theme_window_status_attr" \;\
        setw -g window-status-format "$(_decode_unicode_escapes "$tmux_conf_theme_window_status_format")" \;\
        setw -g window-status-current-style "fg=$tmux_conf_theme_window_status_current_fg,bg=$tmux_conf_theme_window_status_current_bg,$tmux_conf_theme_window_status_current_attr" \;\
        setw -g window-status-current-format "$(_decode_unicode_escapes "$tmux_conf_theme_window_status_current_format")"

  tmux_conf_theme_window_status_activity_fg=${tmux_conf_theme_window_status_activity_fg:-'default'}
  tmux_conf_theme_window_status_activity_bg=${tmux_conf_theme_window_status_activity_bg:-'default'}
  tmux_conf_theme_window_status_activity_attr=${tmux_conf_theme_window_status_activity_attr:-'underscore'}
  tmux setw -g window-status-activity-style "fg=$tmux_conf_theme_window_status_activity_fg,bg=$tmux_conf_theme_window_status_activity_bg,$tmux_conf_theme_window_status_activity_attr"

  tmux_conf_theme_window_status_bell_fg=${tmux_conf_theme_window_status_bell_fg:-'#ffff00'} # yellow
  tmux_conf_theme_window_status_bell_bg=${tmux_conf_theme_window_status_bell_bg:-'default'}
  tmux_conf_theme_window_status_bell_attr=${tmux_conf_theme_window_status_bell_attr:-'blink,bold'}
  tmux setw -g window-status-bell-style "fg=$tmux_conf_theme_window_status_bell_fg,bg=$tmux_conf_theme_window_status_bell_bg,$tmux_conf_theme_window_status_bell_attr"

  tmux_conf_theme_window_status_last_fg=${tmux_conf_theme_window_status_last_fg:-'#00afff'} # light blue
  tmux_conf_theme_window_status_last_bg=${tmux_conf_theme_window_status_last_bg:-'default'}
  tmux_conf_theme_window_status_last_attr=${tmux_conf_theme_window_status_last_attr:-'none'}
  tmux setw -g window-status-last-style "fg=$tmux_conf_theme_window_status_last_fg,bg=$tmux_conf_theme_window_status_last_bg,$tmux_conf_theme_window_status_last_attr"

  # -- indicators

  tmux_conf_theme_pairing=${tmux_conf_theme_pairing:-'👓'}            # U+1F453
  tmux_conf_theme_pairing_fg=${tmux_conf_theme_pairing_fg:-'#e4e4e4'} # white
  tmux_conf_theme_pairing_bg=${tmux_conf_theme_pairing_bg:-'none'}
  tmux_conf_theme_pairing_attr=${tmux_conf_theme_pairing_attr:-'none'}

  tmux_conf_theme_prefix=${tmux_conf_theme_prefix:-'⌨'}             # U+2328
  tmux_conf_theme_prefix_fg=${tmux_conf_theme_prefix_fg:-'#e4e4e4'} # white
  tmux_conf_theme_prefix_bg=${tmux_conf_theme_prefix_bg:-'none'}
  tmux_conf_theme_prefix_attr=${tmux_conf_theme_prefix_attr:-'none'}

  tmux_conf_theme_root=${tmux_conf_theme_root:-'!'}
  tmux_conf_theme_root_fg=${tmux_conf_theme_root_fg:-'none'}
  tmux_conf_theme_root_bg=${tmux_conf_theme_root_bg:-'none'}
  tmux_conf_theme_root_attr=${tmux_conf_theme_root_attr:-'bold,blink'}

  tmux_conf_theme_synchronized=${tmux_conf_theme_synchronized:-'🔒'}  # U+1F512
  tmux_conf_theme_synchronized_fg=${tmux_conf_theme_synchronized_fg:-'none'}
  tmux_conf_theme_synchronized_bg=${tmux_conf_theme_synchronized_bg:-'none'}
  tmux_conf_theme_synchronized_attr=${tmux_conf_theme_synchronized_attr:-'none'}

  # -- status left style

  tmux_conf_theme_status_left=${tmux_conf_theme_status_left-' ❐ #S '}
  tmux_conf_theme_status_left_fg=${tmux_conf_theme_status_left_fg:-'#000000,#e4e4e4,#e4e4e4'}  # black, white , white
  tmux_conf_theme_status_left_bg=${tmux_conf_theme_status_left_bg:-'#ffff00,#ff00af,#00afff'}  # yellow, pink, white blue
  tmux_conf_theme_status_left_attr=${tmux_conf_theme_status_left_attr:-'bold,none,none'}

  tmux_conf_theme_status_left=$(echo "$tmux_conf_theme_status_left" | sed \
    -e "s/#{pairing}/#[fg=$tmux_conf_theme_pairing_fg]#[bg=$tmux_conf_theme_pairing_bg]#[$tmux_conf_theme_pairing_attr]#{?session_many_attached,$tmux_conf_theme_pairing,}/g")

  tmux_conf_theme_status_left=$(echo "$tmux_conf_theme_status_left" | sed \
    -e "s/#{prefix}/#[fg=$tmux_conf_theme_prefix_fg]#[bg=$tmux_conf_theme_prefix_bg]#[$tmux_conf_theme_prefix_attr]#{?client_prefix,$tmux_conf_theme_prefix,}/g")

  tmux_conf_theme_status_left=$(echo "$tmux_conf_theme_status_left" | sed \
    -e "s%#{root}%#[fg=$tmux_conf_theme_root_fg]#[bg=$tmux_conf_theme_root_bg]#[$tmux_conf_theme_root_attr]#(cut -c3- ~/.tmux.conf | sh -s _root #{pane_tty} #D)#[inherit]%g")

  tmux_conf_theme_status_left=$(echo "$tmux_conf_theme_status_left" | sed \
    -e "s%#{synchronized}%#[fg=$tmux_conf_theme_synchronized_fg]#[bg=$tmux_conf_theme_synchronized_bg]#[$tmux_conf_theme_synchronized_attr]#{?pane_synchronized,$tmux_conf_theme_synchronized,}%g")

  if [ -n "$tmux_conf_theme_status_left" ]; then
    status_left=$(awk \
                      -v fg_="$tmux_conf_theme_status_left_fg" \
                      -v bg_="$tmux_conf_theme_status_left_bg" \
                      -v attr_="$tmux_conf_theme_status_left_attr" \
                      -v mainsep="$tmux_conf_theme_left_separator_main" \
                      -v subsep="$tmux_conf_theme_left_separator_sub" '
      function subsplit(s,   l, i, a, r)
      {
        l = split(s, a, ",")
        for (i = 1; i <= l; ++i)
        {
          o = split(a[i], _, "(") - 1
          c = split(a[i], _, ")") - 1
          open += o - c
          o_ = split(a[i], _, "{") - 1
          c_ = split(a[i], _, "}") - 1
          open_ += o_ - c_
          o__ = split(a[i], _, "[") - 1
          c__ = split(a[i], _, "]") - 1
          open__ += o__ - c__

          if (i == l)
            r = sprintf("%s%s", r, a[i])
          else if (open || open_ || open__)
            r = sprintf("%s%s,", r, a[i])
          else
            r = sprintf("%s%s#[fg=%s,bg=%s,%s]%s", r, a[i], fg[j], bg[j], attr[j], subsep)
        }

        gsub(/#\[inherit\]/, sprintf("#[default]#[fg=%s,bg=%s,%s]", fg[j], bg[j], attr[j]), r)
        return r
      }
      BEGIN {
        FS = "|"
        l1 = split(fg_, fg, ",")
        l2 = split(bg_, bg, ",")
        l3 = split(attr_, attr, ",")
        l = l1 < l2 ? (l1 < l3 ? l1 : l3) : (l2 < l3 ? l2 : l3)
      }
      {
        for (i = j = 1; i <= NF; ++i)
        {
          if (open || open_ || open__)
            printf "|%s", subsplit($i)
          else
          {
            if (i > 1)
              printf "#[fg=%s,bg=%s,none]%s#[fg=%s,bg=%s,%s]%s", bg[j_], bg[j], mainsep, fg[j], bg[j], attr[j], subsplit($i)
            else
              printf "#[fg=%s,bg=%s,%s]%s", fg[j], bg[j], attr[j], subsplit($i)
          }

          if (!open && !open_ && !open__)
          {
            j_ = j
            j = j % l + 1
          }
        }
        printf "#[fg=%s,bg=%s,none]%s", bg[j_], "default", mainsep
      }' << EOF
$tmux_conf_theme_status_left
EOF
    )
  fi

  status_left="$status_left "

  # -- status right style

  tmux_conf_theme_status_right=${tmux_conf_theme_status_right-'#{pairing}#{prefix} #{battery_status} #{battery_bar} #{battery_percentage} , %R , %d %b | #{username} | #{hostname} '}
  tmux_conf_theme_status_right_fg=${tmux_conf_theme_status_right_fg:-'#8a8a8a,#e4e4e4,#000000'} # light gray, white, black
  tmux_conf_theme_status_right_bg=${tmux_conf_theme_status_right_bg:-'#080808,#d70000,#e4e4e4'} # dark gray, red, white
  tmux_conf_theme_status_right_attr=${tmux_conf_theme_status_right_attr:-'none,none,bold'}

  tmux_conf_theme_status_right=$(echo "$tmux_conf_theme_status_right" | sed \
    -e "s/#{pairing}/#[fg=$tmux_conf_theme_pairing_fg]#[bg=$tmux_conf_theme_pairing_bg]#[$tmux_conf_theme_pairing_attr]#{?session_many_attached,$tmux_conf_theme_pairing,}/g")

  tmux_conf_theme_status_right=$(echo "$tmux_conf_theme_status_right" | sed \
    -e "s/#{prefix}/#[fg=$tmux_conf_theme_prefix_fg]#[bg=$tmux_conf_theme_prefix_bg]#[$tmux_conf_theme_prefix_attr]#{?client_prefix,$tmux_conf_theme_prefix,}/g")

  tmux_conf_theme_status_right=$(echo "$tmux_conf_theme_status_right" | sed \
    -e "s%#{root}%#[fg=$tmux_conf_theme_root_fg]#[bg=$tmux_conf_theme_root_bg]#[$tmux_conf_theme_root_attr]#(cut -c3- ~/.tmux.conf | sh -s _root #{pane_tty} #D)#[inherit]%g")

  tmux_conf_theme_status_right=$(echo "$tmux_conf_theme_status_right" | sed \
    -e "s%#{synchronized}%#[fg=$tmux_conf_theme_synchronized_fg]#[bg=$tmux_conf_theme_synchronized_bg]#[$tmux_conf_theme_synchronized_attr]#{?pane_synchronized,$tmux_conf_theme_synchronized,}%g")

  if [ -n "$tmux_conf_theme_status_right" ]; then
    status_right=$(awk \
                      -v fg_="$tmux_conf_theme_status_right_fg" \
                      -v bg_="$tmux_conf_theme_status_right_bg" \
                      -v attr_="$tmux_conf_theme_status_right_attr" \
                      -v mainsep="$tmux_conf_theme_right_separator_main" \
                      -v subsep="$tmux_conf_theme_right_separator_sub" '
      function subsplit(s,   l, i, a, r)
      {
        l = split(s, a, ",")
        for (i = 1; i <= l; ++i)
        {
          o = split(a[i], _, "(") - 1
          c = split(a[i], _, ")") - 1
          open += o - c
          o_ = split(a[i], _, "{") - 1
          c_ = split(a[i], _, "}") - 1
          open_ += o_ - c_
          o__ = split(a[i], _, "[") - 1
          c__ = split(a[i], _, "]") - 1
          open__ += o__ - c__

          if (i == l)
            r = sprintf("%s%s", r, a[i])
          else if (open || open_ || open__)
            r = sprintf("%s%s,", r, a[i])
          else
            r = sprintf("%s%s#[fg=%s,bg=%s,%s]%s", r, a[i], fg[j], bg[j], attr[j], subsep)
        }

        gsub(/#\[inherit\]/, sprintf("#[default]#[fg=%s,bg=%s,%s]", fg[j], bg[j], attr[j]), r)
        return r
      }
      BEGIN {
        FS = "|"
        l1 = split(fg_, fg, ",")
        l2 = split(bg_, bg, ",")
        l3 = split(attr_, attr, ",")
        l = l1 < l2 ? (l1 < l3 ? l1 : l3) : (l2 < l3 ? l2 : l3)
      }
      {
        for (i = j = 1; i <= NF; ++i)
        {
          if (open_ || open || open__)
            printf "|%s", subsplit($i)
          else
            printf "#[fg=%s,bg=%s,none]%s#[fg=%s,bg=%s,%s]%s", bg[j], (i == 1) ? "default" : bg[j_], mainsep, fg[j], bg[j], attr[j], subsplit($i)

          if (!open && !open_ && !open__)
          {
            j_ = j
            j = j % l + 1
          }
        }
      }' << EOF
$tmux_conf_theme_status_right
EOF
    )
  fi

  # -- variables

  tmux set -g '@root' "$tmux_conf_theme_root"

  tmux_conf_battery_bar_symbol_full=${tmux_conf_battery_bar_symbol_full:-'◼'}
  tmux_conf_battery_bar_symbol_empty=${tmux_conf_battery_bar_symbol_empty:-'◻'}
  tmux_conf_battery_bar_length=${tmux_conf_battery_bar_length:-'auto'}
  tmux_conf_battery_bar_palette=${tmux_conf_battery_bar_palette:-'gradient'}
  tmux_conf_battery_hbar_palette=${tmux_conf_battery_hbar_palette:-'gradient'} # red, orange, green
  tmux_conf_battery_vbar_palette=${tmux_conf_battery_vbar_palette:-'gradient'} # red, orange, green
  tmux_conf_battery_status_charging=${tmux_conf_battery_status_charging:-'↑'}       # U+2191
  tmux_conf_battery_status_discharging=${tmux_conf_battery_status_discharging:-'↓'} # U+2193

  case "$status_left $status_right" in
    *'#{battery_status}'*|*'#{battery_bar}'*|*'#{battery_hbar}'*|*'#{battery_vbar}'*|*'#{battery_percentage}'*)
      status_left=$(echo "$status_left" | sed -E \
        -e 's/#\{(\?)?battery_bar/#\{\1@battery_bar/g' \
        -e 's/#\{(\?)?battery_hbar/#\{\1@battery_hbar/g' \
        -e 's/#\{(\?)?battery_vbar/#\{\1@battery_vbar/g' \
        -e 's/#\{(\?)?battery_status/#\{\1@battery_status/g' \
        -e 's/#\{(\?)?battery_percentage/#\{\1@battery_percentage/g')
      status_right=$(echo "$status_right" | sed -E \
        -e 's/#\{(\?)?battery_bar/#\{\1@battery_bar/g' \
        -e 's/#\{(\?)?battery_hbar/#\{\1@battery_hbar/g' \
        -e 's/#\{(\?)?battery_vbar/#\{\1@battery_vbar/g' \
        -e 's/#\{(\?)?battery_status/#\{\1@battery_status/g' \
        -e 's/#\{(\?)?battery_percentage/#\{\1@battery_percentage/g')

      tmux  set -g '@battery_bar_symbol_full' "$(_decode_unicode_escapes "$tmux_conf_battery_bar_symbol_full")" \;\
            set -g '@battery_bar_symbol_empty' "$(_decode_unicode_escapes "$tmux_conf_battery_bar_symbol_empty")" \;\
            set -g '@battery_bar_length' "$tmux_conf_battery_bar_length" \;\
            set -g '@battery_bar_palette' "$tmux_conf_battery_bar_palette" \;\
            set -g '@battery_hbar_palette' "$tmux_conf_battery_hbar_palette" \;\
            set -g '@battery_vbar_palette' "$tmux_conf_battery_vbar_palette" \;\
            set -g '@battery_status_charging' "$(_decode_unicode_escapes "$tmux_conf_battery_status_charging")" \;\
            set -g '@battery_status_discharging' "$(_decode_unicode_escapes "$tmux_conf_battery_status_discharging")"
      status_right="#(cut -c3- ~/.tmux.conf | sh -s _battery)$status_right"
      ;;
  esac

  case "$status_left $status_right" in
    *'#{username}'*|*'#{hostname}'*|*'#{username_ssh}'*|*'#{hostname_ssh}'*)
      status_left=$(echo "$status_left" | sed \
        -e 's%#{username}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} false #D)%g' \
        -e 's%#{hostname}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} false #D)%g' \
        -e 's%#{username_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} true #D)%g' \
        -e 's%#{hostname_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} true #D)%g')
      status_right=$(echo "$status_right" | sed \
        -e 's%#{username}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} false #D)%g' \
        -e 's%#{hostname}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} false #D)%g' \
        -e 's%#{username_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _username #{pane_tty} true #D)%g' \
        -e 's%#{hostname_ssh}%#(cut -c3- ~/.tmux.conf | sh -s _hostname #{pane_tty} true #D)%g')
      ;;
  esac

  case "$status_left $status_right" in
    *'#{uptime_d}'*|*'#{uptime_h}'*|*'#{uptime_m}'*|*'#{uptime_s}'*)
      status_left=$(echo "$status_left" | sed -E \
        -e 's/#\{(\?)?uptime_y/#\{\1@uptime_y/g' \
        -e 's/#\{(\?)?uptime_d/#\{\1@uptime_d/g' \
        -e '/@uptime_y/ s/@uptime_d/@uptime_dy/g' \
        -e 's/#\{(\?)?uptime_h/#\{\1@uptime_h/g' \
        -e 's/#\{(\?)?uptime_m/#\{\1@uptime_m/g' \
        -e 's/#\{(\?)?uptime_s/#\{\1@uptime_s/g')
      status_right=$(echo "$status_right" | sed -E \
        -e 's/#\{(\?)?uptime_y/#\{\1@uptime_y/g' \
        -e 's/#\{(\?)?uptime_d/#\{\1@uptime_d/g' \
        -e '/@uptime_y/ s/@uptime_d/@uptime_dy/g' \
        -e 's/#\{(\?)?uptime_h/#\{\1@uptime_h/g' \
        -e 's/#\{(\?)?uptime_m/#\{\1@uptime_m/g' \
        -e 's/#\{(\?)?uptime_s/#\{\1@uptime_s/g')
      status_right="#(cut -c3- ~/.tmux.conf | sh -s _uptime)$status_right"
      ;;
  esac

  case "$status_left $status_right" in
    *'#{loadavg}'*)
      status_left=$(echo "$status_left" | sed -E \
        -e 's/#\{(\?)?loadavg/#\{\1@loadavg/g')
      status_right=$(echo "$status_right" | sed -E \
        -e 's/#\{(\?)?loadavg/#\{\1@loadavg/g')
      status_right="#(cut -c3- ~/.tmux.conf | sh -s _loadavg)$status_right"
      ;;
  esac

  status_left=$(echo "$status_left" | sed 's%#{circled_session_name}%#(cut -c3- ~/.tmux.conf | sh -s _circled #S)%g')
  status_right=$(echo "$status_right" | sed 's%#{circled_session_name}%#(cut -c3- ~/.tmux.conf | sh -s _circled #S)%g')

  tmux  set -g status-left-length 1000 \; set -g status-left "$(_decode_unicode_escapes "$status_left")" \;\
        set -g status-right-length 1000 \; set -g status-right "$(_decode_unicode_escapes "$status_right")"

  # -- clock -------------------------------------------------------------

  tmux_conf_theme_clock_colour=${tmux_conf_theme_clock_colour:-'#00afff'} # light blue
  tmux_conf_theme_clock_style=${tmux_conf_theme_clock_style:-'24'}
  tmux  setw -g clock-mode-colour "$tmux_conf_theme_clock_colour" \;\
        setw -g clock-mode-style "$tmux_conf_theme_clock_style"
}

_apply_configuration() {

  if ! command -v perl > /dev/null 2>&1; then
    tmux run -b 'tmux set display-time 3000 \; display "This configuration requires perl" \; set -u display-time'
    return
  fi
  if ! command -v sed > /dev/null 2>&1; then
    tmux run -b 'tmux set display-time 3000 \; display "This configuration requires sed" \; set -u display-time'
    return
  fi
  if ! command -v awk > /dev/null 2>&1; then
    tmux run -b 'tmux set display-time 3000 \; display "This configuration requires awk" \; set -u display-time'
    return
  fi

  # see https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard
  if command -v reattach-to-user-namespace > /dev/null 2>&1; then
    default_shell="$(tmux show -gv default-shell)"
    case "$default_shell" in
      *fish)
        tmux set -g default-command "reattach-to-user-namespace -l $default_shell"
        ;;
      *sh)
        tmux set -g default-command "exec $default_shell... 2> /dev/null & reattach-to-user-namespace -l $default_shell"
        ;;
    esac
  fi

  _apply_overrides
  _apply_bindings
  _apply_theme
  for name in $(printenv | grep -E -o '^tmux_conf_[^=]+'); do tmux setenv -gu "$name"; done;
}

_urlview() {
  tmux capture-pane -J -S - -E - -b "urlview-$1" -t "$1"
  tmux split-window "tmux show-buffer -b urlview-$1 | urlview || true; tmux delete-buffer -b urlview-$1"
}

_fpp() {
  tmux capture-pane -J -S - -E - -b "fpp-$1" -t "$1"
  tmux split-window "tmux show-buffer -b fpp-$1 | fpp || true; tmux delete-buffer -b fpp-$1"
}

"$@"
