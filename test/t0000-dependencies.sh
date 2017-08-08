#!/bin/env bash

test_description="Check dependencies"

. ./setup.sh


DESC="Fail if enhanced getopt is not available"
shellmock_expect 'getopt' --status 2
test_expect_success "$DESC" '
	test_expect_code 65 $CHAPECRON
'
shellmock_clean


DESC="Fail if bash 4.0+ is not available"
test_expect_failure "$DESC" '
	BASH_VERSINFO=(3) test_expect_code 65 $CHAPECRON
'

test_done

