#!/bin/env bash

test_description="Options handling"

. ./setup.sh


DESC="Fail when invoked with -c or --config for a non existing file"
test_expect_success "$DESC" '
	local TEST_ROOT="$SHARNESS_TRASH_DIRECTORY"
	local TEST_CONF="$TEST_ROOT/chapecron.conf.not-exists"

	test_expect_code 70 "$CHAPECRON" -c "$TEST_CONF" -- date 2>/dev/null
'


DESC="Fail when invoked with -c or --config for a non readable file"
test_expect_success "$DESC" '
	local TEST_ROOT="$SHARNESS_TRASH_DIRECTORY"
	local TEST_CONF="$TEST_ROOT/chapecron.conf.not-unreadable"

	cp "$TEST_HOME/data/chapecron-usr.conf" "$TEST_CONF"
	chmod u-r "$TEST_CONF"

	test_expect_code 70 "$CHAPECRON" -c "$TEST_CONF" -- date 2>/dev/null
'


DESC="Load configuration from file specified via -c or --config when valid"
test_expect_success "$DESC" '
	local TEST_ROOT="$SHARNESS_TRASH_DIRECTORY"
	local TEST_CONFIG="$TEST_ROOT/chapecron.conf.readable"

	cp "$TEST_HOME/data/chapecron-usr.conf" "$TEST_CONFIG"

	"$CHAPECRON" -vvc "$TEST_CONFIG" -- date | \
		grep "Loading configuration from file $TEST_CONFIG" > /dev/null
'


DESC="Load the correct configuration from a file"
test_expect_success "$DESC" '
	local TEST_ROOT="$SHARNESS_TRASH_DIRECTORY"
	local TEST_CONFIG="$TEST_ROOT/chapecron.conf.checked"

	cat > config-expected <<-EXPECTED
		-- Configuration loaded --
		plugins = log time
		-- Configuration ends --
	EXPECTED

	cp "$TEST_HOME/data/chapecron-usr.conf" "$TEST_CONFIG"

	"$CHAPECRON" -vvc "$TEST_CONFIG" -- date | \
		sed -e "/-- Configuration loaded --/,/-- Configuration ends --/!d" > config
	test_cmp config config-expected
'


DESC="Load system and/or user configuration when invoked without options"
test_expect_success "$DESC" '
	local TEST_ROOT="$SHARNESS_TRASH_DIRECTORY"
	local SYS_CONFIG="$TEST_ROOT/etc/chapecron/chapecron.conf"
	local USR_CONFIG="$TEST_ROOT/home/$(whoami)/.config/chapecron/chapecron.conf"


	cat > expected <<-EXPECTED
		Loading configuration from file $SYS_CONFIG
		Loading configuration from file $USR_CONFIG
	EXPECTED

	mkdir -p "$(dirname "$SYS_CONFIG")"
	mkdir -p "$(dirname "$USR_CONFIG")"
	cp "$TEST_HOME/data/chapecron-sys.conf" "$SYS_CONFIG"
	cp "$TEST_HOME/data/chapecron-usr.conf" "$USR_CONFIG"

	CHAPECRON_PATH_PREFIX="$TEST_ROOT" "$CHAPECRON" -v -- date | \
		sed -e "/Loading configuration from file/!d" > output
	test_cmp output expected
'


DESC="Merge system and user configurations"
test_expect_success "$DESC" '
	local TEST_ROOT="$SHARNESS_TRASH_DIRECTORY"
	local SYS_CONFIG="$TEST_ROOT/etc/chapecron/chapecron.conf"
	local USR_CONFIG="$TEST_ROOT/home/$(whoami)/.config/chapecron/chapecron.conf"

	cat > config-expected <<-EXPECTED
		-- Configuration loaded --
		plugins = log time
		log.path = /var/log/chapecron/chapecron.log
		-- Configuration ends --
	EXPECTED

	mkdir -p "$(dirname "$SYS_CONFIG")"
	mkdir -p "$(dirname "$USR_CONFIG")"
	cp "$TEST_HOME/data/chapecron-sys.conf" "$SYS_CONFIG"
	cp "$TEST_HOME/data/chapecron-usr.conf" "$USR_CONFIG"

	CHAPECRON_PATH_PREFIX="$TEST_ROOT" "$CHAPECRON" -vv -- date | \
		sed -e "/-- Configuration loaded --/,/-- Configuration ends --/!d" > config
	test_cmp config config-expected
'


test_done

