#!/usr/bin/env bash
#
# This script checks that a dependency is installed in `$(pwd)/lib/$DEPENDENCY`.
# If not, it will clone it from $REPOSITORY. If not uptodate with $VERSION, it
# will fetch the specified version from $REPOSITORY.
#
# Inspired from the install-sharness.sh script from Sharnessify, written by
# Juan Batiz-Benet and Christian Couder.
#

DEPENDENCY=$1
REPOSITORY=$2
VERSION=$3

LIB_DIR=$(realpath "$(dirname $0)")/lib

# Ensure LIB_DIR exists
mkdir -p "$LIB_DIR" || die "Could not create $LIB_DIR"

if [ -f "$LIB_DIR/$DEPENDENCY/VERSION_$VERSION" ]; then
	exit 0
fi

die() {
	echo >&2 "$@"
	exit 1
}

if [ -d "$LIB_DIR/$DEPENDENCY/.git" ]; then
	# Update required
	cd "$LIB_DIR/$DEPENDENCY" && git fetch -q || die "Could not fetch updates"
else
	# Clone required
	cd "$LIB_DIR" && git clone -q "$REPOSITORY" "$DEPENDENCY" || die "Could not clone '$REPOSITORY'"
fi

cd "$LIB_DIR/$DEPENDENCY"  || die "Local version of $REPOSITORY does not exists"
git checkout -q "$VERSION" || die "Could not checkout '$VERSION'"
rm -f VERSION_*            || die "Could not remove 'VERSION_*'"
touch "VERSION_$VERSION"   || die "Could not create 'VERSION_$VERSION'"

echo "$DEPENDENCY version $VERSION is checked out!"

exit 0
