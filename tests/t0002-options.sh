#!/bin/env bash

test_description="Options handling"

. ./setup.sh


DESC="Fail when invoked without a command to monitor"
test_expect_success "$DESC" '
	test_expect_code  64 $CHAPECRON 2>/dev/null
'


DESC="Output version information when invoked with --version"
test_expect_success "$DESC" '
	$CHAPECRON --version | grep "Version: " > /dev/null
'


DESC="Output help when invoked with -h or --help"
test_expect_success "$DESC" '
	$CHAPECRON -h | grep "Usage: chapecron" > /dev/null && \
	$CHAPECRON --help | grep "Usage: chapecron" > /dev/null
'


DESC="Output more informations when invoked with -v or --verbose"
test_expect_success "$DESC" '
	$CHAPECRON -v -- date | grep "Command to be monitored: date" > /dev/null && \
	$CHAPECRON --verbose -- date | grep "Command to be monitored: date" > /dev/null
'


DESC="Support more than one level of verbosity"
test_expect_success "$DESC" '
	$CHAPECRON --verbose --verbose date | grep "verbose = 2" > /dev/null
'


test_done
