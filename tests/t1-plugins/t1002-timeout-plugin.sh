#!/usr/bin/env bash

test_description="Timeout plugin"

. ./setup.sh

DESC="Fail if not configured"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::timeout
	CONFIG

	test_expect_code 78 "$CHAPECRON" -c config -- uname -a
'


DESC="Kill long running command"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::timeout
		timeout.duration=1s
	CONFIG

	local begin_at=$(date +"%s")
	"$CHAPECRON" -c config -- sleep 10 2>/dev/null
	local end_at=$(date +"%s")
	local diff=$(($end_at - $begin_at))

	[ $diff -lt 5 ]
'

test_done
