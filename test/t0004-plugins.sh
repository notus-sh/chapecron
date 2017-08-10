#!/bin/env bash

test_description="Plugins loading"

. ./setup.sh


DESC="Should load plugins"
test_expect_success "$DESC" '
	cat > plugins-expected <<-EXPECTED
		-- Plugins available --
		chapecron::log
		chapecron::time
		-- Plugins ends --
	EXPECTED

	"$CHAPECRON" -vv -- date | \
		sed -e "/-- Plugins available --/,/-- Plugins ends --/!d" > plugins
	test_cmp plugins plugins-expected
'


DESC="Should fail if a configured plugin is not available"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_config="$test_root/chapecron.conf.plugin-unavailable"

	cp "$TEST_HOME/data/chapecron-plugins-wrong.conf" "$test_config"

	test_expect_code 78 "$CHAPECRON" -c "$test_config" -- date 2>/dev/null
'


DESC="Should add configured plugins to the stack"
test_expect_success "$DESC" '
	local -r test_root="$SHARNESS_TRASH_DIRECTORY"
	local -r test_config="$test_root/chapecron.conf.plugin"

	cat > stack-expected <<-EXPECTED
		-- Stack build --
		chapecron::mktmp
		chapecron::capture
		chapecron::log
		chapecron::time
		chapecron::command
		-- Stack ends --
	EXPECTED

	cp "$TEST_HOME/data/chapecron-plugins.conf" "$test_config"

	"$CHAPECRON" -vvc "$test_config" -- date | \
		sed -e "/-- Stack build --/,/-- Stack ends --/!d" > stack
	test_cmp stack stack-expected
'


test_done

