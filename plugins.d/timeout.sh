#!/bin/env bash

chapecron::timeout() {
	[ ${CONFIG['timeout.duration']+isset} ] || \
		utils::fail $EX_CONFIG \
								"Missing configuration: timeout.limit"

	local exit_code options=""
	[ ${CONFIG['timeout.signal']+isset} ] && options+=" --signal=${CONFIG['timeout.signal']}"
	[ ${CONFIG['timeout.kill']+isset} ] && options+=" --kill-after=${CONFIG['timeout.kill']}"

	context::export

	timeout $options "${CONFIG['timeout.duration']}" "$CHAPECRON_BIN" -r
	exit_code=$?

	if [ $exit_code = 124 ]; then
		utils::error "Command has been killed by timeout"
	fi
	return $exit_code
}
