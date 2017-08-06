# This file should be sourced by all test-scripts
#
# This scripts sets the following:
#   $TEST_HOME	This folder
#   $CHAPECRON	Full path to script to test

# We must be called from tests/
cd "$(dirname "$0")"
TEST_HOME="$(pwd)"

CHAPECRON="$TEST_HOME/../chapecron"

if [[ ! -e $CHAPECRON ]]
then
	echo "Could not find chapecron"
	exit 1
fi

. ./lib/sharness/sharness.sh
