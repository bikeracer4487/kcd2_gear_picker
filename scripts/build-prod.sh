#!/bin/bash

projectRoot="$(dirname "$(realpath "$0")")/.."
defaultVariant="main"

variant="${1:-$defaultVariant}"

echo "Running prod build (variant: $variant)..."

cd "$projectRoot" || { echo "ERROR: Cannot change to $projectRoot"; exit 1; }

manifestFile="$projectRoot/src/mod.manifest"
modIdentifier=$(grep -oP '<modid>\K[^<]+' "$manifestFile")
modVersion=$(grep -oP '<version>\K[^<]+' "$manifestFile")
[ "$modIdentifier" ] && [ "$modVersion" ] || { echo "ERROR: Could not extract modid or variant from $manifestFile"; exit 1; }

zipFileName="${modIdentifier}_${variant}_${modVersion}.zip"
zipFilePath="./$zipFileName"

docker compose run --rm -e MODE="prod" -e VARIANT="$variant" ci-cd
[ -f "$zipFilePath" ] || { echo "ERROR: ZIP $zipFilePath not found!"; exit 1; }
docker compose down ci-cd -v

echo "Production build complete: $zipFileName"