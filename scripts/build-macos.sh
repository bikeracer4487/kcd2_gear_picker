#!/bin/bash

# Updated build script for macOS
# This builds the GearPicker mod into a PAK file compatible with KCD2

# Set variables
PROJECT_ROOT="$(dirname "$(cd "$(dirname "$0")" && pwd)")"
TARGET="main"
MOD_SRC_DIR="$PROJECT_ROOT/src/$TARGET"
BUILD_DIR="$PROJECT_ROOT/build_macos"
TEMP_DIR="$BUILD_DIR/temp"

echo "----------------------------------------------"
echo "Building GearPicker mod for KCD2..."
echo "----------------------------------------------"

# Create clean build directory
echo "Cleaning build directories..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$TEMP_DIR/Data/Scripts"

# Read manifest file to get mod details
MANIFEST_FILE="$MOD_SRC_DIR/mod.manifest"
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "ERROR: Manifest file not found at $MANIFEST_FILE"
    exit 1
fi

MOD_ID=$(sed -n 's/.*<modid>\(.*\)<\/modid>.*/\1/p' "$MANIFEST_FILE")
MOD_VERSION=$(sed -n 's/.*<version>\(.*\)<\/version>.*/\1/p' "$MANIFEST_FILE")
MOD_NAME=$(sed -n 's/.*<n>\(.*\)<\/n>.*/\1/p' "$MANIFEST_FILE")

if [ -z "$MOD_ID" ] || [ -z "$MOD_VERSION" ]; then
    echo "ERROR: Could not extract mod ID or version from manifest file"
    exit 1
fi

echo "Building mod: $MOD_NAME ($MOD_ID) version $MOD_VERSION"

# Copy all files from source to build dir
cp -r "$MOD_SRC_DIR/Data" "$TEMP_DIR/"

# Create Data directory and PAK file
DATA_DIR="$TEMP_DIR/Data"
PAK_FILE="$DATA_DIR/${MOD_ID}.pak"

echo "Verifying file structure..."
if [ ! -d "$DATA_DIR/Scripts/GearPicker" ]; then
    echo "WARN: GearPicker scripts directory not found at $DATA_DIR/Scripts/GearPicker"
    
    # Check if we have HelmetOffDialog directory instead and GearPicker.lua
    if [ -d "$DATA_DIR/Scripts/HelmetOffDialog" ] && [ -f "$DATA_DIR/Scripts/GearPicker/GearPicker.lua" ]; then
        echo "INFO: Found both HelmetOffDialog directory and GearPicker files"
        echo "This is expected during migration from HelmetOffDialog to GearPicker"
    fi
fi

# Confirm that critical files exist
for CRITICAL_FILE in "$DATA_DIR/Scripts/GearPicker/GearPicker.lua" "$DATA_DIR/Scripts/GearPicker/GearScan.lua" "$DATA_DIR/Scripts/Systems/GearPicker_Listeners.lua"; do
    if [ ! -f "$CRITICAL_FILE" ]; then
        echo "WARNING: Critical file not found: $CRITICAL_FILE"
        echo "The mod may not function correctly!"
    else
        echo "Verified: $CRITICAL_FILE"
    fi
done

echo "Creating PAK file ($PAK_FILE)..."

# Change to the Data directory to create the PAK file
cd "$DATA_DIR"

# Get a list of all files to pack (excluding any existing PAK files)
FILE_LIST=$(find . -type f -not -name "*.pak")

# Display some info about what's being packed
TOTAL_FILES=$(echo "$FILE_LIST" | wc -l)
echo "Packing $TOTAL_FILES files into PAK..."

# Create the PAK file using zip with specific options for game compatibility
zip -r -9 -X "$PAK_FILE" $FILE_LIST

# Verify the PAK file was created
if [ ! -f "$PAK_FILE" ]; then
    echo "ERROR: Failed to create PAK file"
    exit 1
fi

# Check PAK file size
PAK_SIZE=$(du -h "$PAK_FILE" | cut -f1)
echo "PAK file created successfully: $PAK_SIZE"

# Clean up all non-PAK files from the Data directory
find "$DATA_DIR" -type f -not -name "*.pak" -delete
find "$DATA_DIR" -type d -empty -delete

# Create final mod structure
mkdir -p "$TEMP_DIR/$MOD_ID"
mv "$DATA_DIR" "$TEMP_DIR/$MOD_ID/"

# Copy manifest and modding EULA to the mod folder
cp "$MOD_SRC_DIR/mod.manifest" "$TEMP_DIR/$MOD_ID/"
cp "$PROJECT_ROOT/src/modding_eula.txt" "$TEMP_DIR/$MOD_ID/"

echo "Copied mod.manifest and modding_eula.txt to mod package"

# Create final zip file
cd "$TEMP_DIR"
ZIP_FILE="$BUILD_DIR/${MOD_ID}_${MOD_VERSION}.zip"
zip -r -9 -X "$ZIP_FILE" "$MOD_ID"

# Verify zip content
echo "Verifying ZIP file contents..."
unzip -l "$ZIP_FILE"

ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
echo "Build complete! Mod file created at: $ZIP_FILE ($ZIP_SIZE)"

# If KCD2 directory exists, deploy the mod
if [ "$1" = "deploy" ]; then
    # Try to locate the KCD2 directory
    if [ -d "/Applications/Steam/steamapps/common/KingdomComeDeliverance2" ]; then
        KCD2_DIR="/Applications/Steam/steamapps/common/KingdomComeDeliverance2"
    elif [ -d "$HOME/Library/Application Support/Steam/steamapps/common/KingdomComeDeliverance2" ]; then
        KCD2_DIR="$HOME/Library/Application Support/Steam/steamapps/common/KingdomComeDeliverance2"
    elif [ -d "/mnt/c/Steam/steamapps/common/KingdomComeDeliverance2" ]; then
        KCD2_DIR="/mnt/c/Steam/steamapps/common/KingdomComeDeliverance2"
    elif [ -d "/mnt/c/Program Files (x86)/Steam/steamapps/common/KingdomComeDeliverance2" ]; then
        KCD2_DIR="/mnt/c/Program Files (x86)/Steam/steamapps/common/KingdomComeDeliverance2"
    else
        echo "KCD2 directory not found automatically. Please specify it as the second argument."
        echo "Example: ./build-macos.sh deploy \"/path/to/KCD2\""
        if [ -n "$2" ] && [ -d "$2" ]; then
            KCD2_DIR="$2"
        else
            exit 1
        fi
    fi
    
    if [ -d "$KCD2_DIR" ]; then
        echo "Deploying mod to KCD2 Mods directory..."
        MODS_DIR="$KCD2_DIR/Mods"
        mkdir -p "$MODS_DIR"
        
        # Clean existing mod files before deployment
        MOD_DESTINATION="$MODS_DIR/$MOD_ID"
        if [ -d "$MOD_DESTINATION" ]; then
            echo "Removing existing mod files from $MOD_DESTINATION..."
            rm -rf "$MOD_DESTINATION"
        fi
        
        # Extract mod to mods folder
        echo "Extracting new mod files..."
        unzip -o "$ZIP_FILE" -d "$MODS_DIR"
        
        # Update mod_order.txt
        MOD_ORDER_FILE="$MODS_DIR/mod_order.txt"
        touch "$MOD_ORDER_FILE"
        if ! grep -q "$MOD_ID" "$MOD_ORDER_FILE"; then
            echo "$MOD_ID" >> "$MOD_ORDER_FILE"
            echo "Added $MOD_ID to $MOD_ORDER_FILE"
        fi
        
        echo "----------------------------------------------"
        echo "Mod deployed successfully to $MOD_DESTINATION"
        echo "----------------------------------------------"
    else
        echo "KCD2 directory not found at $KCD2_DIR"
    fi
fi