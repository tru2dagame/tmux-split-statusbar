#!/usr/bin/env bash
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/scripts/helpers.sh"

main() {
  split_bind_key
  set_default_status_format

  local split_statusbar_mode="$(tmux show-option -gqv "@split-statusbar-mode")"
  if [[ "${split_statusbar_mode}" = "on" ]];then
    split_statusbar_on
  fi
  if [[ "${split_statusbar_mode}" = "off" ]];then
    split_statusbar_off
  fi

  local toggle_flag="$1"
  if [[ "${toggle_flag}" = "toggle" ]];then
    split_statusbar_toggle
  fi

}

main "$1"
