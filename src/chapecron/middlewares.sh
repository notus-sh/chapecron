#!/bin/bash

# Chapecron
chapecron::mktmp() {
	export TMP=$(mktemp -d 'chapecron.XXXXXXXXXX')
	export OUT=$TMP/cronic.out
	export ERR=$TMP/cronic.err
	export TRACE=$TMP/cronic.trace
	
	trap "{ rm -rf $TMP; }" EXIT
	
	stack::next
}

chapecron::run() {
	set +e
	stack::next >$OUT 2>$TRACE
	RESULT=$?
	set -e
	
	PATTERN="^${PS4:0:1}\\+${PS4:1}"
	if grep -aq "$PATTERN" $TRACE
	then
		! grep -av "$PATTERN" $TRACE > $ERR
	else
		ERR=$TRACE
	fi
	
	if [ $RESULT -ne 0 -o -s "$ERR" ]
	then
		echo -e $(chapecron::trace $COMMAND)
	fi
}

chapecron::trace() {
	echo "Cronic detected failure or error output for the command:"
	echo "$@"
	echo
	echo "RESULT CODE: $RESULT"
	echo
	echo "ERROR OUTPUT:"
	cat "$ERR"
	echo
	echo "STANDARD OUTPUT:"
	cat "$OUT"
	if [ $TRACE != $ERR ]
	then
		echo
		echo "TRACE-ERROR OUTPUT:"
		cat "$TRACE"
	fi
}
