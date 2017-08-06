#!/bin/sh

test_description="Options handling"

. ./setup.sh


DESC="Should fail of enhanced getopt is not available"
shellmock_expect 'getopt' --status 2
test_expect_success "$DESC" '
	test_expect_code 1 $CHAPECRON
'
shellmock_clean


DESC="Output help when invoked with -h"
test_expect_success "$DESC" '
  $CHAPECRON -h | grep "chapecron: look after your crons"
'


DESC="Output help when invoked with --help"
test_expect_success "$DESC" '
  $CHAPECRON --help | grep "chapecron: look after your crons"
'


DESC="Output parsed parameters when invoked with -v"
test_expect_success "$DESC" '
  $CHAPECRON -v date | grep "verbose: 1, help: 0, command: date"
'


DESC="Output parsed parameters when invoked with --verbose"
test_expect_success "$DESC" '
  $CHAPECRON --verbose date | grep "verbose: 1, help: 0, command: date"
'


test_done

# vi: set ft=sh :
