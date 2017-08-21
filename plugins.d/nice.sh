#!/usr/bin/env bash

chapecron::nice() {
	local -i adjustment=0 exit_code=0 nice_value=0

	if [ ${CONFIG['nice.adjustment']+isset} ]; then
		adjustment+=${CONFIG['nice.adjustment']}
	else
		adjustment=10
	fi

	context::export
	/usr/bin/env nice --adjustment=$adjustment "$CHAPECRON_BIN" -r
	exit_code=$?

	if [ $exit_code -ge 125 ] && [ $exit_code -le 127 ]; then
		utils::error "Unable to invoke the next middleware with nice ($exit_code)"
	fi

	return $exit_code
}
