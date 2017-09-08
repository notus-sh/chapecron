#!/usr/bin/env bash

test_description="Unique jobs plugin"

. ./setup.sh

DESC="Do nothing when a single instance is called"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::unique
	CONFIG

	"$CHAPECRON" -vvc config -- uname
'


DESC="Prevent multiple execution of the same script"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::unique
	CONFIG

	"$CHAPECRON" -vvc config -e "sleep 15" &
	sleep 5
	test_expect_code 75 "$CHAPECRON" -vvc config -e "sleep 15"
'

test_done
