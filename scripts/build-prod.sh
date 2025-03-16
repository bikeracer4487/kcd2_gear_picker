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

manifestFile="$projectRoot/src/mod.manifest"
modIdentifier=$(grep -oP '<modid>\K[^<]+' "$manifestFile")
modVersion=$(grep -oP '<version>\K[^<]+' "$manifestFile")
[ "$modIdentifier" ] && [ "$modVersion" ] || { echo "ERROR: Could not extract modid or version from $manifestFile"; exit 1; }

# Define expected zip file name based on target
zipFileName="${modIdentifier}_${target}_${modVersion}.zip"
zipFilePath="$projectRoot/$zipFileName"

# Run the build in Docker
docker compose run --rm -e MODE="prod" -e TARGET="$target" ci-cd

# Copy the zip file from the container to the host
container_id=$(docker ps -lq)
docker cp "$container_id:/app/$zipFileName" "$zipFilePath" || {
  echo "ERROR: Failed to copy $zipFileName from container!"
  docker compose down -v
  exit 1
}
[ -f "$zipFilePath" ] || { echo "ERROR: ZIP $zipFilePath not found!"; exit 1; }

docker compose down -v

echo "Production build complete: $zipFileName"