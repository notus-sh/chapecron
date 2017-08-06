#!/bin/sh

test_description="Basic features"

. ./setup.sh

test_expect_success "Output nothing on success" '
	test -z "$($CHAPECRON date)"
'

test_expect_success "Output nothing on standard output on failure" '
	test -z "$(2>/dev/null $CHAPECRON date -w)"
'

test_expect_success "Output something on standard error output on failure" '
	test -n "$(2>&1 $CHAPECRON date -w)"
'

test_done

# vi: set ft=sh :
