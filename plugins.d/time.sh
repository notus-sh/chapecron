#!/usr/bin/env bash

chapecron::time() {
	/usr/bin/env time --help > /dev/null || \
		utils::fail $EX_UNAVAILABLE \
								"Missing dependency: time"

	[ ${CONFIG['time.path']+isset} ] || \
		utils::fail $EX_CONFIG \
								"Missing configuration: time.path"

	[ ${CONFIG['time.format']+isset} ] || \
		utils::fail $EX_CONFIG \
								"Missing configuration: time.format"

	local format="$(printf "%s - %s -- %s" "$(date '+%Y-%m-%d %H:%M:%S')" "$COMMAND" "${CONFIG['time.format']}")"
	local path="${CONFIG['time.path']}"

	context::export
	/usr/bin/env time --format="$format" -ao "$path" -- "$CHAPECRON_BIN" -r
	return $?
}
