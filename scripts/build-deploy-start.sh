#!/bin/bash

projectRoot="$(dirname "$(realpath "$0")")/.."
defaultGamePath="/mnt/c/Steam/steamapps/common/KingdomComeDeliverance2"
exeName="KingdomCome.exe"
defaultExeSubPath="Bin/Win64MasterMasterSteamPGO/${exeName}"
defaultTarget="main"

# List of all valid mod targets (mirrors validTargets in build.js)
validTargets=("main" "random" "ranged" "helmet_only")

echo "Script called with arguments: $@"

# Check if an argument is provided
if [ -z "$1" ] || [ "$1" = "kcd1" ]; then
    if [ "$1" = "kcd1" ]; then
        gamePath="/mnt/c/Steam/steamapps/common/KingdomComeDeliverance"
        exeSubPath="Bin/Win64/${exeName}"
    else
        gamePath="$defaultGamePath"
        exeSubPath="$defaultExeSubPath"
    fi
    echo "Building and deploying all mods: ${validTargets[*]}"
    targets=("${validTargets[@]}")
else
    gamePath="$defaultGamePath"
    exeSubPath="$defaultExeSubPath"
    target="$1"
    # Validate the target against validTargets
    if [[ ! " ${validTargets[@]} " =~ " ${target} " ]]; then
        echo "ERROR: Invalid target '$target'. Must be one of: ${validTargets[*]}"
        exit 1
    fi
    targets=("$target")
fi

modsPath="${gamePath}/Mods"
modOrderFile="$modsPath/mod_order.txt"

# Kill the game process if running (suppress error if not found)
taskkill.exe /F /IM "${exeName}" 2>/dev/null || true
sleep 1

echo "Running dev build and deploy..."

cd "$projectRoot" || { echo "ERROR: Cannot change to $projectRoot"; exit 1; }

# Build and deploy each target
for target in "${targets[@]}"; do
    echo "Building and deploying target: $target"

    # Use the correct manifest file for each target
    manifestFile="$projectRoot/src/$target/mod.manifest"
    if [ ! -f "$manifestFile" ]; then
        echo "ERROR: Manifest file not found at $manifestFile"
        exit 1
    fi

    modIdentifier=$(grep -oP '<modid>\K[^<]+' "$manifestFile")
    modVersion=$(grep -oP '<version>\K[^<]+' "$manifestFile")
    [ "$modIdentifier" ] && [ "$modVersion" ] || {
        echo "ERROR: Could not extract modid or version from $manifestFile";
        exit 1;
    }

    zipFileName="${modIdentifier}_${modVersion}.zip"
    zipFilePath="./$zipFileName"

    # Run the build for this target
    docker compose run --rm -e MODE="dev" -e TARGET="$target" ci-cd
    [ -f "$zipFilePath" ] || { echo "ERROR: ZIP $zipFilePath not found!"; exit 1; }

    # Extract the zip to the mods folder
    sevenZipBinary="$projectRoot/node_modules/7z-bin/linux/7zzs"
    "$sevenZipBinary" x "$zipFilePath" -o"$modsPath" -y || {
        echo "ERROR: Failed to extract $zipFilePath with 7zzs";
        exit 1;
    }
    echo "Extracted $zipFileName to $modsPath"

    # Update mod_order.txt if necessary
    if [ -f "$modOrderFile" ]; then
        modOrder=$(cat "$modOrderFile" | tr -d '\r');
    else
        modOrder="";
    fi
    echo "$modOrder" | grep -Fxq "$modIdentifier" || {
        echo "$modOrder" > "$modOrderFile";
        echo "$modIdentifier" >> "$modOrderFile";
        echo "Added $modIdentifier to $modOrderFile";
    }
done

docker compose down -v

# Start the game (commented out for now)
 echo "Starting the game..."
 ${gamePath}/${exeSubPath}