#!/bin/sh

test_description="Show basic features of chapecron"

. ./lib/sharness/sharness.sh

CHAPECRON=../chapecron

test_expect_success "Output nothing on success" '
	test -z $($CHAPECRON date)
'

test_expect_success "Output nothing on standard output on failure" '
	test -z $(2>/dev/null $CHAPECRON date -w)
'

test_expect_success "Output something on standard error output on failure" '
	test -n $(1>/dev/null $CHAPECRON date -w)
'

test_done

# vi: set ft=sh :
