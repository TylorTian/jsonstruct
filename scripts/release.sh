#!/usr/bin/env bash
set -euo pipefail

PART=${1:-patch}

# Extract current version
CURRENT_VERSION=$(sed -nE 's/^version = "([0-9]+)\.([0-9]+)\.([0-9]+)"/\1.\2.\3/p' pyproject.toml)
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

case "$PART" in
  major) ((MAJOR+=1)); MINOR=0; PATCH=0 ;;
  minor) ((MINOR+=1)); PATCH=0 ;;
  patch) ((PATCH+=1)) ;;
  *) echo "❌ Unknown version part: $PART"; exit 1 ;;
esac

NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"

# Prevent duplicate tags
if git rev-parse "v$NEW_VERSION" >/dev/null 2>&1; then
  echo "❌ Git tag v$NEW_VERSION already exists. Aborting release."
  exit 1
fi

echo -e "\n✨ Bumping version ($PART -> $NEW_VERSION)"
bump2version --allow-dirty --new-version "$NEW_VERSION" --tag "$PART"

RELEASE_VERSION="$NEW_VERSION"
echo -e "\n📦 Releasing version: $RELEASE_VERSION"
echo "🔍 Confirm pyproject.toml version:"
grep '^version = ' pyproject.toml

# Git push + tag
git push
git push origin "v$RELEASE_VERSION"

echo "🧹 Cleaning old builds"
rm -rf dist/ build/ *.egg-info

echo "📦 Building package"
python -m build

echo "🚀 Uploading to PyPI"
if ! twine upload dist/*; then
  echo "❌ PyPI upload failed. Possible reason: version already exists."
  echo "🛑 Aborting to prevent duplicate release."
  exit 1
fi

echo "🍺 Updating Homebrew Formula"
PYPI_TARBALL="https://files.pythonhosted.org/packages/source/j/jsonstruct-cli/jsonstruct_cli-${RELEASE_VERSION}.tar.gz"

for i in {1..10}; do
  echo "⏳ Waiting for PyPI tarball availability ($i/10)..."
  if curl -fsI "$PYPI_TARBALL" > /dev/null; then
    echo "✅ PyPI tarball is available"
    break
  fi
  sleep 5
done

ruby scripts/update-formula.rb "$RELEASE_VERSION"
cd ../homebrew-tap
git add Formula/jsonstruct.rb
git commit -m "chore: bump jsonstruct to v$RELEASE_VERSION"
git push
cd -

REPO="TylorTian/jsonstruct"
TAG="v$RELEASE_VERSION"
GITHUB_RUN_API="https://api.github.com/repos/${REPO}/actions/runs"

echo "🔍 Checking GitHub Actions status for tag $TAG ..."
for i in {1..10}; do
  sleep 5
  echo "⏳ Checking attempt $i..."

  latest_run=$(curl -s "$GITHUB_RUN_API?event=push&per_page=1" | jq -r '.workflow_runs[0]')
  run_id=$(echo "$latest_run" | jq -r '.id')
  run_url=$(echo "$latest_run" | jq -r '.html_url')
  run_status=$(echo "$latest_run" | jq -r '.status')
  run_conclusion=$(echo "$latest_run" | jq -r '.conclusion')
  run_tag=$(echo "$latest_run" | jq -r '.head_branch')

  if [[ "$run_tag" == "main" || "$run_tag" == "$TAG" ]]; then
    if [[ "$run_status" == "completed" ]]; then
      if [[ "$run_conclusion" == "success" ]]; then
        echo "✅ GitHub Actions succeeded for $TAG"
        break
      else
        echo "❌ GitHub Actions failed for $TAG: $run_url"
        break
      fi
    else
      echo "⏳ GitHub Action still in progress... ($run_status)"
    fi
  fi
done

echo -e "\n✅ Released v$RELEASE_VERSION successfully."

