# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#
#   $TEST_HOME	This folder
#   $CHAPECRON	Full path to script to test
#

# We must be called from tests/
cd "$(dirname "$0")"

TEST_HOME="$(pwd)"

if (! realpath -e "$TEST_HOME/../chapecron" > /dev/null); then
	echo "Could not find chapecron" >&2
	exit 1
fi
CHAPECRON="$(realpath -e "$TEST_HOME/../chapecron")"

. ./lib/sharness/sharness.sh
