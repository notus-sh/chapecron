#!/usr/bin/env bash

test_description="Check dependencies"

. ./setup.sh


DESC="Fail if enhanced getopt is not available"
shellmock_expect 'getopt' --status 2
test_expect_success "$DESC" '
	test_expect_code 69 "$CHAPECRON" $ERROR_REDIRECT
'
shellmock_clean


DESC="Fail if bash 4.0+ is not available"
test_expect_success "$DESC" '
	CHAPECRON_BASH_VERSION=3 test_expect_code 69 "$CHAPECRON" $ERROR_REDIRECT
'

test_done
