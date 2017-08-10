#!/bin/env bash

test_description="Options handling"

. ./setup.sh


DESC="Output help when invoked with -h or --help"
test_expect_success "$DESC" '
	$CHAPECRON -h | grep "chapecron: look after your crons" > /dev/null && \
	$CHAPECRON --help | grep "chapecron: look after your crons" > /dev/null
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
