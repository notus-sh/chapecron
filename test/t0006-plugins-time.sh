#!/bin/env bash

test_description="Time plugin"

. ./setup.sh

if [ ! -e "/usr/bin/time" ]; then

	DESC="Should fail if time is not available"
	test_expect_success "$DESC" '
		cat > config <<-CONFIG
			plugins=chapecron::time
		CONFIG

		test_expect_code 69 "$CHAPECRON" -c config -- uname -a
	'

else

	DESC="Should fail if not configured"
	test_expect_success "$DESC" '
		cat > config <<-CONFIG
			plugins=chapecron::time
		CONFIG

		test_expect_code 78 "$CHAPECRON" -c config -- uname -a
	'


	DESC="Should append timing to the configured log file"
	test_expect_success "$DESC" '
		local -r test_root="$SHARNESS_TRASH_DIRECTORY"
		local -r test_log="$test_root/chapecron.log"

		cat > config <<-CONFIG
			plugins=chapecron::time
			time.path=$test_log
			time.format=Real: %e - Kernel: %S
		CONFIG

		echo some-text >> "$test_log"

		"$CHAPECRON" -c config -- uname -a

		pcregrep -e "^some-text$" "$test_log" > /dev/null &&
		grep -e "uname -a" "$test_log" > /dev/null &&
		pcregrep -e "Real: [\d]\.[\d]{2} - Kernel: [\d]\.[\d]{2}" "$test_log" > /dev/null
	'

fi

test_done
