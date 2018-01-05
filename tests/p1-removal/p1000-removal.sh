#!/usr/bin/env bash

test_description="Check removal"

. ./setup.sh


DESC="Fail if chapecron files are still present"
test_expect_success "$DESC" '
	test_expect_code 1 [ -d /usr/lib/chapecron ]
'


DESC="Fail if default configuration file is still present"
test_expect_success "$DESC" '
	test_expect_code 1 [ -d /etc/chapecron ]
'


DESC="Fail if symlink has not been removed"
test_expect_success "$DESC" '
	test_expect_code 1 [ -L /usr/bin/chapecron ]
'

test_done
