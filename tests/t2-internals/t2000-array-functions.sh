#!/usr/bin/env bash

test_description="Array functions"

. ./setup.sh
. $CHAPECRON


DESC="Find an item in an array with array::search"
test_expect_success "$DESC" "
	test_expect_code 0 array::search 1 1 2 3
	test_expect_code 1 array::search 0 1 2 3
"

DESC="Find an exact string in an array with array::search"
test_expect_success "$DESC" "
	test_expect_code 0 array::search yearly daily weekly monthly yearly
	test_expect_code 1 array::search year daily weekly monthly yearly
"


DESC="Merge two or more arrays with array::merge"
test_expect_success "$DESC" "
	array::merge 'apple banana orange' 'banana grape' > output
	cat > expected <<-EXPECTED
		apple banana orange grape
	EXPECTED
	test_cmp output expected
"


test_done
