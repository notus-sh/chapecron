# This file should be sourced by all test-scripts
#
# This scripts sets the following variables that can be used in tests:
#
#   $TEST_HOME	This folder
#   $CHAPECRON	Full path to script to test
#   $VENDOR_DIR	Installation folder of external dependencies
#

# We must be called from tests/
cd "$(dirname "${BASH_SOURCE[0]}")"
declare -r TEST_HOME="$(pwd -P)"

if (! readlink -e "$TEST_HOME/../chapecron" > /dev/null); then
	echo "Could not find chapecron" >&2
	exit 1
fi
declare -r CHAPECRON="$(readlink -e "$TEST_HOME/../chapecron")"

declare -r VENDOR_DIR="$(readlink -e "$(dirname $TEST_HOME)/vendor")"


# Set Sharness test dir to tests/
declare -r SHARNESS_TEST_SRCDIR="$TEST_HOME"
# Configure test_cmp() to ignore trailing whitespaces
declare -r TEST_CMP="diff -Zu"

source $VENDOR_DIR/sharness/sharness.sh


declare DESC
