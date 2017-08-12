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
	cat > config <<-CONFIG
		plugins=chapecron::log chapecron::wrong
	CONFIG

	test_expect_code 78 "$CHAPECRON" -c config -- date 2>/dev/null
'


DESC="Should add configured plugins to the stack"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		plugins=chapecron::log chapecron::time
		log.path="/var/log/chapecron/chapecron.log"
		time.format="Real: %e - Kernel: %S - User: %U - Inputs: %I - Outputs: %O"
		time.path="/var/log/chapecron/time.log"
	CONFIG

	cat > stack-expected <<-EXPECTED
		-- Stack build --
		chapecron::mktmp
		chapecron::capture
		chapecron::log
		chapecron::time
		chapecron::command
		-- Stack ends --
	EXPECTED

	"$CHAPECRON" -vvc config -- date | \
		sed -e "/-- Stack build --/,/-- Stack ends --/!d" > stack
	test_cmp stack stack-expected
'


test_done
