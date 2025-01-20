#!/bin/bash

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

echo "New commits since the last tag"

# generate changelog
convco check $COMMIT_HASH_LAST_TAG..$COMMIT_HASH_CURRENT

cog bump --auto

# # generate changelog
# convco changelog --output CHANGELOG.md --first-parent

# # generate version
# NEW_VERSION=$( convco version --bump)
# echo "New version: $NEW_VERSION"

# # # commit changelog and version
# # git add CHANGELOG.md && git commit -m "chore: update CHANGELOG"
# # git add Cargo.toml && git commit -m "chore: update version"

# # # push to remote
# # git push origin HEAD
