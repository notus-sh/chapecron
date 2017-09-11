#!/usr/bin/env bash
#
# This script checks that a dependency is installed in `$(pwd)/lib/$DEPENDENCY`.
# If not, it will clone it from $REPOSITORY. If not uptodate with $VERSION, it
# will fetch the specified version from $REPOSITORY.
#
# Inspired from the install-sharness.sh script from Sharnessify, written by
# Juan Batiz-Benet and Christian Couder.
#

DEPENDENCY="$1"
REPOSITORY="$2"
VERSION="$3"

VENDOR_DIR="$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")/vendor"

# Ensure LIB_DIR exists
mkdir -p "$VENDOR_DIR" || die "Could not create $VENDOR_DIR"

if [ -f "$VENDOR_DIR/$DEPENDENCY/VERSION_$VERSION" ]; then
	exit 0
fi

die() {
	echo >&2 "$@"
	exit 1
}

if [ -d "$VENDOR_DIR/$DEPENDENCY/.git" ]; then
	# Update required
	cd "$VENDOR_DIR/$DEPENDENCY" && git fetch -q || die "Could not fetch updates"
else
	# Clone required
	cd "$VENDOR_DIR" && git clone -q "$REPOSITORY" "$DEPENDENCY" || die "Could not clone '$REPOSITORY'"
fi

cd "$VENDOR_DIR/$DEPENDENCY"  || die "Local version of $REPOSITORY does not exists"
git checkout -q "$VERSION" || die "Could not checkout '$VERSION'"
rm -f VERSION_*            || die "Could not remove 'VERSION_*'"
touch "VERSION_$VERSION"   || die "Could not create 'VERSION_$VERSION'"

echo "$DEPENDENCY version $VERSION is checked out!"

exit 0
