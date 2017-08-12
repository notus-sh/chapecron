#!/bin/env bash

test_description="Log plugin"

. ./setup.sh


DESC="Should fail if not configured"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_config="$test_root/chapecron.conf.plugin-log-wrong"

	cat > "$test_config" <<-CONFIG
		plugins=chapecron::log
	CONFIG

	test_expect_code 78 "$CHAPECRON" -c "$test_config" -- uname -a
'


DESC="Should append command's output to the configured log file"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_config="$test_root/chapecron.conf.plugin-log"
	local -r test_log="$test_root/chapecron-log.log"

	cat > "$test_config" <<-CONFIG
		plugins=chapecron::log
		log.path=$test_log
	CONFIG

	echo some-text >> "$test_log"
	echo some-text >> expected
	uname -a >> expected

	"$CHAPECRON" -c "$test_config" -- uname -a
	test_cmp "$test_log" expected
'


test_done
