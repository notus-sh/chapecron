#!/bin/sh
# install-shellmock.sh
#
# Copyright (c) 2014 Juan Batiz-Benet
# Copyright (c) 2015 Christian Couder
# MIT Licensed; see the LICENSE file in this repository.
#
# This script checks that Bash Shell Mock is installed in:
#
# $(pwd)/$clonedir/$bsmdir/
#
# where $clonedir and $bsmdir are configured below.
#
# If shellmock is not installed, this script will clone it
# from $urlprefix (defined below).
#
# If shell mock is not uptodate with $version (defined below),
# this script will fetch and will update the installed
# version to $version.
#

# settings
version=8fd1b4b21e5f3f323b1664f658dc7e085095adb8
urlprefix=https://github.com/capitalone/bash_shell_mock.git
clonedir=lib
bsmdir=shellmock

if test -f "$clonedir/$bsmdir/VERSION_$version"
then
    # There is the right version file. Great, we are done!
    exit 0
fi

die() {
    echo >&2 "$@"
    exit 1
}

checkout_version() {
    git checkout "$version" || die "Could not checkout '$version'"
    rm -f VERSION_* || die "Could not remove 'VERSION_*'"
    touch "VERSION_$version" || die "Could not create 'VERSION_$version'"
    echo "Bash Shell Mock version $version is checked out!"
}

if test -d "$clonedir/$bsmdir/.git"
then
    # We need to update sharness!
    cd "$clonedir/$bsmdir" || die "Could not cd into '$clonedir/$bsmdir' directory"
    git fetch || die "Could not fetch to update sharness"
else
    # We need to clone sharness!
    mkdir -p "$clonedir" || die "Could not create '$clonedir' directory"
    cd "$clonedir" || die "Could not cd into '$clonedir' directory"

    git clone "$urlprefix" "$bsmdir" || die "Could not clone '$urlprefix'"
    cd "$bsmdir" || die "Could not cd into '$bsmdir' directory"
fi

checkout_version
