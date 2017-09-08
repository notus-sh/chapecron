#!/usr/bin/env bash

test_description="Configuration loading"

. ./setup.sh


DESC="Fail when invoked with -c or --config for a non existing file"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_config="$test_root/chapecron.conf.not-exists"

	test_expect_code 72 "$CHAPECRON" -c "$test_config" -- date 2>/dev/null
'


DESC="Fail when invoked with -c or --config for a non readable file"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_config="$test_root/chapecron.conf.not-readable"

	touch "$test_config"
	chmod u-r "$test_config"

	test_expect_code 72 "$CHAPECRON" -c "$test_config" -- date 2>/dev/null
'


DESC="Load configuration from file specified via -c or --config when valid"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_config="$test_root/chapecron.conf.readable"

	touch "$test_config"

	"$CHAPECRON" -vvc "$test_config" -- date | \
		grep "Loading configuration from file $test_config" > /dev/null
'


DESC="Load the correct configuration from a file"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::log chapecron::time
		sample-key=user
	CONFIG

	cat > expected <<-EXPECTED
		middlewares = chapecron::log chapecron::time
		sample-key = user
	EXPECTED

	"$CHAPECRON" -vvc config -- date | \
		sed -e "/^-- Configuration loaded --/,/^-- Configuration ends --/!d" | \
		grep -v "Configuration" | \
		sort > output
	test_cmp output expected
'


DESC="Load system and/or user configuration when invoked without options"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r sys_config="$test_root/etc/chapecron/chapecron.conf"
	local -r usr_config="$test_root/home/$(whoami)/.config/chapecron/chapecron.conf"

	cat > expected <<-EXPECTED
		Loading configuration from file $sys_config
		Loading configuration from file $usr_config
	EXPECTED

	mkdir -p "$(dirname "$sys_config")"
	mkdir -p "$(dirname "$usr_config")"
	touch "$sys_config"
	touch "$usr_config"

	CHAPECRON_PATH_PREFIX="$test_root" "$CHAPECRON" -vv -- date | \
		grep -e "Loading configuration from file" > output
	test_cmp output expected
'


DESC="Merge system and user configurations"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r sys_config="$test_root/etc/chapecron/chapecron.conf"
	local -r usr_config="$test_root/home/$(whoami)/.config/chapecron/chapecron.conf"

	mkdir -p "$(dirname "$sys_config")"
	mkdir -p "$(dirname "$usr_config")"

	cat > "$sys_config" <<-SYS_CONFIG
		sample-key=sys
		middlewares=chapecron::time
	SYS_CONFIG

	cat > "$usr_config" <<-SYS_CONFIG
		sample-key=user
		middlewares=chapecron::log chapecron::time
	SYS_CONFIG

	cat > expected <<-EXPECTED
		middlewares = chapecron::time chapecron::log
		sample-key = user
	EXPECTED

	CHAPECRON_PATH_PREFIX="$test_root" "$CHAPECRON" -vv -- date | \
		sed -e "/^-- Configuration loaded --/,/^-- Configuration ends --/!d" | \
		grep -v "Configuration" | \
		sort > output
	test_cmp output expected
'


test_done
