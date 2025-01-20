#!/bin/bash
set -e

# Turn on bash safety options: fail on error, variable unset and error in piped process
set -eou pipefail

# ARGS
IMAGE_NAME=$1
DOKERFILE_PATH=./docker/build/$1/Dockerfile
REPOSITORY=$2
GIT_ROOT=$(git rev-parse --show-toplevel)

# Check if the correct number of arguments (2 or 3) are passed
if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
    echo "Usage: $0 <image-name> <repository> [tag-type]"
    exit 1
fi

# If the user did not supply a third arg, default to 'commit'
TAG_TYPE="${3:-commit}"
VERSION="$(grep -E '^version\s*=\s*' "$GIT_ROOT/Cargo.toml" | sed -nE 's/^version\s*=\s*"([^"]+)"/\1/p' | head -n 1)"

# Get the current commit hash
COMMIT_HASH=$(git rev-parse --short=7 HEAD)

# Get the current branch name and replace any '/' with '.'
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
SANITIZED_BRANCH_NAME=${BRANCH_NAME//\//.}

# Get the machine hardware name
ARCH=$(uname -m)

# Determine the platform name suffix based on the architecture
case "$ARCH" in
    x86_64)
        PLATFORM="linux/amd64"
        PLATFORM_SUFFIX="-amd64"
        ;;
    aarch64)
        PLATFORM="linux/arm64"
        PLATFORM_SUFFIX="-arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

CONTAINER_TAG_COMMIT="${REPOSITORY}/${IMAGE_NAME}:${COMMIT_HASH}${PLATFORM_SUFFIX}"
echo "CONTAINER_TAG_COMMIT: ${CONTAINER_TAG_COMMIT}"
CONTAINER_TAG_BRANCH="${REPOSITORY}/${IMAGE_NAME}:${VERSION}-${SANITIZED_BRANCH_NAME}${PLATFORM_SUFFIX}"
echo "CONTAINER_TAG_BRANCH: ${CONTAINER_TAG_BRANCH}"
CONTAINER_TAG_RELEASE="${REPOSITORY}/${IMAGE_NAME}:${VERSION}${PLATFORM_SUFFIX}"
echo "CONTAINER_TAG_RELEASE: ${CONTAINER_TAG_RELEASE}"

declare -a TAGS
case "$TAG_TYPE" in
    commit)
        echo "Building Docker image tagged with commit hash only..."
        TAGS=("${CONTAINER_TAG_COMMIT}")
        ;;
    branch)
        echo "Building Docker image with both commit and branch tags..."
        TAGS=("${CONTAINER_TAG_COMMIT}" "${CONTAINER_TAG_BRANCH}")
        ;;
    release)
        echo "Building Docker image with commit and release tags..."
        TAGS=("${CONTAINER_TAG_COMMIT}" "${CONTAINER_TAG_RELEASE}")
        ;;
    *)
        echo "Invalid tag type: $TAG_TYPE"
        exit 1
        ;;
esac

# Build the Docker image with all relevant tags
docker buildx build "$GIT_ROOT" \
    -f "$DOKERFILE_PATH" \
    --platform "$PLATFORM" \
    $(printf -- '-t %s ' "${TAGS[@]}")
