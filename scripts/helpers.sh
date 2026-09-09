# Set-option requests a redraw even if the value is unchanged. Never use these
# helpers from a status-left/status-right #() expression; apply on load/toggle.
set_status_option() {
  local name="$1" value="$2" current
  # The first two status choices are named off/on, followed by 2, 3, ... .
  if [[ "$name" = "status" ]]; then
    [[ "$value" = "1" ]] && value=on
    [[ "$value" = "0" ]] && value=off
  fi
  current="$(tmux show-option -gqv "$name")" || return
  [[ "$current" = "$value" ]] && return 0
  tmux set-option -g "$name" "$value"
}

# --------------------- bind key ---------------------
split_bind_key() {
  # Only remove this plugin's run-shell bindings. xargs -i is not portable to
  # macOS, and the installed path need not be ~/.tmux/plugins.
  local binding table key command
  while read -r binding; do
    [[ "$binding" = *tmux-split-statusbar.tmux* ]] || continue
    read -r _ _ table key command <<< "$binding"
    [[ "$command" = run-shell\ * ]] && tmux unbind-key -T "$table" "$key"
  done < <(tmux list-keys)

  # Define bind key for status bar togle
  local bind_key="$(tmux show-option -gqv "@split-statusbar-bindkey")"
  [[ -z "${bind_key}" ]] && bind_key="M-s"
  local -a key_args
  read -r -a key_args <<< "$bind_key"
  local entrypoint
  printf -v entrypoint '%q' "$CURRENT_DIR/tmux-split-statusbar.tmux"
  tmux bind-key "${key_args[@]}" run-shell "$entrypoint toggle"

  # Define bind key for status left right toggle
  local bind_key_hide="$(tmux show-option -gqv "@split-status-hide-bindkey")"
  [[ -z "${bind_key_hide}" ]] && bind_key_hide="M-d"
  read -r -a key_args <<< "$bind_key_hide"
  tmux bind-key "${key_args[@]}" run-shell "$entrypoint hide"
}

# --------------------- Initialize ---------------------
# --- backup default setting ---
#  status-format[6]       -  status_format_0_default
#  status-format[7]       -  status_format_1_default
#  @status-left-default   -  status_left_default
#  @status-right-default  -  status_right_default
set_default_status_format() {
  local status_format_0_default="$(tmux show-option -gqv "status-format[6]")"
  #local status_format_1_default="$(tmux show-option -gqv "status-format[7]")"

  if [[ -z "${status_format_0_default}" ]]; then
    # --- status line ---
    local status_format_0_default="$(tmux show-option -gqv "status-format[0]")"
    local status_format_1_default="$(tmux show-option -gqv "status-format[1]")"
    set_status_option status-format[6] "${status_format_0_default}"
    set_status_option status-format[7] "${status_format_1_default}"

    # --- status left right ---
    local status_left_default="$(tmux show-option -gqv "status-left")"
    local status_right_default="$(tmux show-option -gqv "status-right")"
    set_status_option @status-left-default "${status_left_default}"
    set_status_option @status-right-default "${status_right_default}"
  fi
}

# --------------------- statusbar lines ---------------------
split_statusbar_on() {
  local status_format_0_default="$(tmux show-option -gqv "status-format[6]")"

  # status_format_0_tobe="$(echo "${status_format_0_default}" | sed 's/:status-left//g' | sed 's/:status-right//g')"
  local status_format_1_tobe="${status_format_0_default//\#\{T;=\/\#\{status-left-length\}:status-left\}/}"
  status_format_1_tobe="${status_format_1_tobe//\#\{T;=\/\#\{status-right-length\}:status-right\}/}"
  local status_format_0_tobe="${status_format_0_default//:window-status-current-format/}"
  status_format_0_tobe="${status_format_0_tobe//:window-status-format/}"
  set_status_option status-format[0] "${status_format_0_tobe}"
  set_status_option status-format[1] "${status_format_1_tobe}"
  set_status_option status 2
}

split_statusbar_off() {
  local status_format_0_default="$(tmux show-option -gqv "status-format[6]")"
  local status_format_1_default="$(tmux show-option -gqv "status-format[7]")"

  set_status_option status-format[0] "${status_format_0_default}"
  set_status_option status-format[1] "${status_format_1_default}"
  set_status_option status on
}

split_statusbar_toggle() {
  local status_format_current="$(tmux show-option -gqv "status-format[0]")"
  local status_format_0_default="$(tmux show-option -gqv "status-format[6]")"
  if [[ "${status_format_current}" = "${status_format_0_default}" ]]; then
    split_statusbar_on
    set_status_option @split-statusbar-mode-setto "on"
  else
    split_statusbar_off
    set_status_option @split-statusbar-mode-setto "off"
  fi
}

# --------------------- hide status left right ---------------------
hide_status_on() {
  set_status_option status-left "#[fg=colour232,bg=red,bold]#{?client_prefix, <PREFIX> ,}#[fg=colour232,bg=colour203,bold]#{?pane_in_mode, <COPY> ,}"
  set_status_option status-right ""

  # For support tmux-coninuum
  local check_plugin_status="$(cat ~/.tmux.conf |awk '/^[ \t]*set(-option)? +-g +@plugin/ { gsub(/'\''/,""); gsub(/'\"'/,""); print $4 }' | grep 'tmux-plugins/tmux-continuum')"

  if [[ -n "${check_plugin_status}" ]]; then
    #if [[ -f ~/.tmux/plugins/tmux-continuum/continuum.tmux ]]; then
    #  ~/.tmux/plugins/tmux-continuum/continuum.tmux >/dev/null 2>/dev/null
    #fi
    local plugin_script="$(readlink -m ~/.tmux/plugins/tmux-continuum/scripts/continuum_save.sh)"
    if [[ -f "${plugin_script}" ]]; then
      set_status_option status-right "#(${plugin_script})"
    fi

  fi

}

hide_status_off() {
  local status_left_default="$(tmux show-option -gqv "@status-left-default")"
  local status_right_default="$(tmux show-option -gqv "@status-right-default")"
  set_status_option status-left "${status_left_default}"
  set_status_option status-right "${status_right_default}"
}

hide_status_toggle() {
  local status_left_current="$(tmux show-option -gqv "status-left")"
  local status_left_default="$(tmux show-option -gqv "@status-left-default")"
  if [[ "${status_left_current}" = "${status_left_default}" ]]; then
    hide_status_on
    set_status_option @hide-statusbar-mode-setto "on"
  else
    hide_status_off
    set_status_option @hide-statusbar-mode-setto "off"
  fi
}
