#!/bin/bash

echo "Checking for conventional commits"

# get current commit hash
COMMIT_HASH_CURRENT=$(git rev-parse HEAD)

# get the last tag on the current branch
LAST_TAG=$(git describe --tags --abbrev=0)

# get the commit hash of the last tag
COMMIT_HASH_LAST_TAG=$(git rev-list -n 1 $LAST_TAG)

# check if the current commit hash is the same as the last tag commit hash
if [ "$COMMIT_HASH_CURRENT" == "$COMMIT_HASH_LAST_TAG" ]; then
    echo "No new commits since the last tag"
    exit 0
fi

# generate changelog
CONVENTIONAL_COMMITS=$(convco check $COMMIT_HASH_LAST_TAG..$COMMIT_HASH_CURRENT)

if echo "$CONVENTIONAL_COMMITS" | grep -qi "fail"; then
    echo "Failures found in conventional commits"
    exit 1
fi

echo "No failures found in conventional commits"
exit 0

