#!/bin/env bash

test_description="Basic features"

. ./setup.sh

DESC="Output nothing on success"
test_expect_success "$DESC" '
	test -z "$($CHAPECRON date)"
'


DESC="Output nothing on standard output on failure"
test_expect_success "$DESC" '
	test -z "$(2>/dev/null $CHAPECRON date -w)"
'


DESC="Output something on standard error output on failure"
test_expect_success "$DESC" '
	test -n "$(2>&1 $CHAPECRON date -w)"
'


test_done
