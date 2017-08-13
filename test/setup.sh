# This file should be sourced by all test-scripts
#
# This scripts sets the following variables that can be used in tests:
#
#   $TEST_HOME	This folder
#   $CHAPECRON	Full path to script to test
#

# We must be called from tests/
cd "$(dirname "$0")"
declare -r TEST_HOME="$(pwd)"

if (! realpath -e "$TEST_HOME/../chapecron" > /dev/null); then
	echo "Could not find chapecron" >&2
	exit 1
fi
declare -r CHAPECRON="$(realpath -e "$TEST_HOME/../chapecron")"

source ./lib/sharness/sharness.sh

# Configure test_cmp() to ignore trailing whitespaces
declare -r TEST_CMP="diff -Zu"

declare DESC
