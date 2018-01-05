#!/usr/bin/env bash

test_description="Check installation"

. ./setup.sh


DESC="Fail if chapecron files are not present"
test_expect_success "$DESC" '
	test_expect_code 0 [ -d /usr/lib/chapecron ]
	test_expect_code 0 [ -f /usr/lib/chapecron/chapecron ]
	test_expect_code 0 [ -d /usr/lib/chapecron/plugins.d ]
	test_expect_code 0 [ "0" != "$(ls -l /usr/lib/chapecron/plugins.d | wc -l)" ]
'


DESC="Fail if license files are not present"
test_expect_success "$DESC" '
	test_expect_code 0 [ -f /usr/lib/chapecron/COPYING ]
	test_expect_code 0 [ -f /usr/lib/chapecron/LICENSE ]
'


DESC="Fail if default configuration file is not present"
test_expect_success "$DESC" '
	test_expect_code 0 [ -d /etc/chapecron ]
	test_expect_code 0 [ -f /etc/chapecron/chapecron.conf ]
'


DESC="Fail if symlink has not been created"
test_expect_success "$DESC" '
	test_expect_code 0 [ -L /usr/bin/chapecron ]
'


DESC="Fail if chapecron does not work"
test_expect_success "$DESC" '
	test_expect_code 0 chapecron -h
'

test_done
