# File: scripts/bump-version.sh

#!/bin/bash

set -e

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 [patch|minor|major]"
  exit 1
fi

VERSION_FILE="pyproject.toml"
CURRENT_VERSION=$(grep '^version =' $VERSION_FILE | cut -d '"' -f2)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case $1 in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  *)
    echo "Invalid version bump type: $1"
    exit 1
    ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
echo "Bumping version: $CURRENT_VERSION → $NEW_VERSION"

sed -i '' "s/version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" $VERSION_FILE

git add $VERSION_FILE
git commit -m "release: bump version to $NEW_VERSION"
git tag "v$NEW_VERSION"
git push origin main
git push origin "v$NEW_VERSION"

