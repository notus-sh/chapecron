#!/bin/env bash

test_description="Plugins loading"

. ./setup.sh


DESC="Load plugins from plugin directory"
test_expect_success "$DESC" "
	cat > plugins-expected <<-EXPECTED
		-- Plugins available --
		chapecron::hatch
		chapecron::stursky
		-- Plugins ends --
	EXPECTED

	CHAPECRON_PLUGIN_PATTERN=$'/dummies/*.sh' \"$CHAPECRON\" -vv -- date | \
		sed -e '/^-- Plugins available --/,/^-- Plugins ends --/!d' > plugins
	test_cmp plugins plugins-expected
"


DESC="Fail if trying to load plugins from another directory"
test_expect_success "$DESC" "
	export CHAPECRON_PLUGIN_PATTERN=$'/../test/sharness.d/*.sh'
	test_expect_code 64 \"$CHAPECRON\" -- date 2>/dev/null
"


DESC="Fail if a configured plugin is not available"
test_expect_success "$DESC" "
	cat > config <<-CONFIG
		plugins=chapecron::stursky chapecron::hatch chapecron::huggy
	CONFIG

	export CHAPECRON_PLUGIN_PATTERN=$'/dummies/*.sh'
	test_expect_code 78 \"$CHAPECRON\" -c config -- date 2>/dev/null
"


DESC="Add configured plugins to the stack"
test_expect_success "$DESC" "
	cat > config <<-CONFIG
		plugins=chapecron::stursky chapecron::hatch
	CONFIG

	cat > stack-expected <<-EXPECTED
		-- Stack build --
		chapecron::mktmp
		chapecron::capture
		chapecron::stursky
		chapecron::hatch
		chapecron::command
		-- Stack ends --
	EXPECTED

	CHAPECRON_PLUGIN_PATTERN=$'/dummies/*.sh' \"$CHAPECRON\" -vvc config -- date | \
		sed -e '/^-- Stack build --/,/^-- Stack ends --/!d' > stack
	test_cmp stack stack-expected
"


DESC="Support plugins that invoke a subshell"
test_expect_success "$DESC" "
	cat > config <<-CONFIG
		plugins=chapecron::stursky
	CONFIG

	cat > expected <<-EXPECTED
		-- Context rebuild --
		= Command to be monitored: date
		= -- Command line options detected --
		= recall = 1
		= verbose = 2
		= -- Command line options ends --
		= -- Configuration loaded --
		= plugins = chapecron::stursky
		= -- Configuration ends --
		= -- Plugins available --
		= chapecron::hatch
		= chapecron::stursky
		= -- Plugins ends --
		= -- Stack build --
		= chapecron::mktmp
		= chapecron::capture
		= chapecron::stursky
		= chapecron::command
		= -- Stack ends --
		-- Context ends --
	EXPECTED

	CHAPECRON_PLUGIN_PATTERN=$'/dummies/*.sh' \"$CHAPECRON\" -vvc config -- date | \
		sed -e '/^-- Context rebuild --/,/^-- Context ends --/!d' > context
	test_cmp context expected
"


test_done
