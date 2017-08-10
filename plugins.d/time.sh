#!/bin/env bash

chapecron::time() {
  local _format="$(printf "%s - %s -- %s" "$(date '+%Y-%m-%d %H:%M:%S')" "$COMMAND" ${CONFIG['time.format']})"
  local _path="${CONFIG['time.path']}"
  
	time --format="$_format" -ao "$_path" -- stack::next
}
