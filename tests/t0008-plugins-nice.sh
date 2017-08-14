#!/bin/env bash

test_description="Nice plugin"

. ./setup.sh

DESC="Work without configuration"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::nice
	CONFIG

	cat > expected <<-EXPECTED
		ERROR OUTPUT:
		10
	EXPECTED

	 2>&1 "$CHAPECRON" -c config -- "nice >&2" | \
		grep -A 1 -e "ERROR OUTPUT:" > output

	test_cmp output expected
'


DESC="Work with configuration"
test_expect_success "$DESC" '
	cat > config <<-CONFIG
		middlewares=chapecron::nice
		nice.adjustment=12
	CONFIG

	cat > expected <<-EXPECTED
		ERROR OUTPUT:
		12
	EXPECTED

	 2>&1 "$CHAPECRON" -c config -- "nice >&2" | \
		grep -A 1 -e "ERROR OUTPUT:" > output

	test_cmp output expected
'

test_done
