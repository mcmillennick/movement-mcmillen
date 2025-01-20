#!/bin/bash

# check if git is installed
if ! command -v git &> /dev/null; then
    echo "git is not installed"
    exit 1
fi

# check if convco is installed
if ! command -v convco &> /dev/null; then
    echo "convco is not installed"
    exit 1
fi

# check if cog is installed
if ! command -v cog &> /dev/null; then
    echo "cocogitto (cog) is not installed"
    exit 1
fi

echo "Creating semantic release"

# get current commit hash
COMMIT_HASH_CURRENT=$(git rev-parse HEAD)
echo "Current commit hash: $COMMIT_HASH_CURRENT"

# get the last tag on the current branch
LAST_TAG=$(git describe --tags --abbrev=0)
echo "Last tag: $LAST_TAG"

# get the commit hash of the last tag
COMMIT_HASH_LAST_TAG=$(git rev-list -n 1 $LAST_TAG)
echo "Last tag commit hash: $COMMIT_HASH_LAST_TAG"

# check if the current commit hash is the same as the last tag commit hash
if [ "$COMMIT_HASH_CURRENT" == "$COMMIT_HASH_LAST_TAG" ]; then
    echo "No new commits since the last tag"
    exit 1
fi

# generate changelog
CONVENTIONAL_COMMITS=$(convco check $COMMIT_HASH_LAST_TAG..$COMMIT_HASH_CURRENT)

if echo "$CONVENTIONAL_COMMITS" | grep -qi "fail"; then
    echo "Failures found in conventional commits"
    exit 1
fi

echo "No failures found in conventional commits"

# bump version
echo "Bumping version"
cog bump --auto

# output the new version
NEW_VERSION=$(convco version --bump)
echo "New version: $NEW_VERSION"

exit 0
