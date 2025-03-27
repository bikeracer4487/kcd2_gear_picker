#!/bin/bash

projectRoot="$(dirname "$(realpath "$0")")/.."
defaultTarget="main"

target="${1:-$defaultTarget}"

# Validate target
valid_targets=("main" "random" "ranged" "helmet_only")
if [[ ! " ${valid_targets[@]} " =~ " ${target} " ]]; then
  echo "ERROR: Invalid target '$target'. Must be one of: ${valid_targets[*]}"
  exit 1
fi

echo "Running prod build (target: $target)..."

cd "$projectRoot" || { echo "ERROR: Cannot change to $projectRoot"; exit 1; }

# Manifest file is now in src/{target}/mod.manifest
manifestFile="$projectRoot/src/$target/mod.manifest"
if [ ! -f "$manifestFile" ]; then
  echo "ERROR: Manifest file not found at $manifestFile"
  exit 1
fi

modIdentifier=$(grep -oP '<modid>\K[^<]+' "$manifestFile")
modVersion=$(grep -oP '<version>\K[^<]+' "$manifestFile")
modName=$(grep -oP '<name>\K[^<]+' "$manifestFile")
[ "$modIdentifier" ] && [ "$modVersion" ] && [ "$modName" ] || {
  echo "ERROR: Could not extract modid, version, or name from $manifestFile";
  exit 1;
}

# Define expected zip file name using modName instead of modIdentifier_target
zipFileName="${modIdentifier}_${modVersion}.zip"
zipFilePath="$projectRoot/$zipFileName"

# Run the build in Docker
docker compose run --rm -e MODE="prod" -e TARGET="$target" dev

# Verify the zip file exists (no need to copy since volume is shared)
[ -f "$zipFilePath" ] || {
  echo "ERROR: ZIP $zipFilePath not found!";
  docker compose down -v
  exit 1;
}

docker compose down -v

echo "Production build complete: $zipFileName"