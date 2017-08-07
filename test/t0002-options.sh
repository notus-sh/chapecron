#!/bin/sh

test_description="Options handling"

. ./setup.sh


DESC="Output help when invoked with -h or --help"
test_expect_success "$DESC" '
  $CHAPECRON -h | grep "chapecron: look after your crons" && \
  $CHAPECRON --help | grep "chapecron: look after your crons"
'


DESC="Output more informations when invoked with -v or --verbose"
test_expect_success "$DESC" '
  $CHAPECRON -v -- date | grep "Command to be monitored: date" && \
  $CHAPECRON --verbose -- date | grep "Command to be monitored: date"
'


DESC="Support more than one level of verbosity"
test_expect_success "$DESC" '
  $CHAPECRON --verbose --verbose date | grep "verbose: 2"
'


test_done

# vi: set ft=sh :
