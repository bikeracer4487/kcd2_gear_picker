#!/bin/bash

# Build script for macOS using Python PAK builder
# This builds the GearPicker mod into a PAK file compatible with KCD2

# Exit on error
set -e

# Set variables for paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="main"
MOD_SRC_DIR="$PROJECT_ROOT/src/$TARGET"
BUILD_DIR="$PROJECT_ROOT/build_macos"
TEMP_DIR="$BUILD_DIR/temp"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

echo "============================================="
echo "Building GearPicker Mod for KCD2..."
echo "============================================="

# Check for Python installation
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed or not in PATH"
    echo "Please install Python 3.6+ from https://www.python.org/downloads/"
    exit 1
fi

# Create clean build directory
echo "Cleaning build directories..."
if [ -d "$BUILD_DIR" ]; then
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"
mkdir -p "$TEMP_DIR/gear_picker"
mkdir -p "$TEMP_DIR/gear_picker/Data"

# Read manifest file to get mod details
MANIFEST_FILE="$MOD_SRC_DIR/mod.manifest"
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "ERROR: Manifest file not found at $MANIFEST_FILE"
    exit 1
fi

# Hard-code the values as a fallback
MOD_ID="gear_picker"
MOD_VERSION="1.1.0"
MOD_NAME="Gear Picker"

# Extract values from manifest
if [ -f "$MANIFEST_FILE" ]; then
    MOD_ID_TEMP=$(grep -o '<modid>.*</modid>' "$MANIFEST_FILE" | sed 's/<modid>\(.*\)<\/modid>/\1/')
    if [ ! -z "$MOD_ID_TEMP" ]; then
        MOD_ID=$MOD_ID_TEMP
    fi
    
    MOD_VERSION_TEMP=$(grep -o '<version>.*</version>' "$MANIFEST_FILE" | sed 's/<version>\(.*\)<\/version>/\1/')
    if [ ! -z "$MOD_VERSION_TEMP" ]; then
        MOD_VERSION=$MOD_VERSION_TEMP
    fi
    
    MOD_NAME_TEMP=$(grep -o '<n>.*</n>' "$MANIFEST_FILE" | sed 's/<n>\(.*\)<\/n>/\1/')
    if [ ! -z "$MOD_NAME_TEMP" ]; then
        MOD_NAME=$MOD_NAME_TEMP
    fi
fi

echo "Building mod: $MOD_NAME ($MOD_ID) version $MOD_VERSION"

# Copy all files from source to build dir
echo "Copying source files..."
cp -R "$MOD_SRC_DIR/Data/"* "$TEMP_DIR/$MOD_ID/Data/"
cp "$MOD_SRC_DIR/mod.manifest" "$TEMP_DIR/$MOD_ID/"
echo "Copied mod.manifest to build directory"

# Define Data directory and PAK file paths
DATA_DIR="$TEMP_DIR/$MOD_ID/Data"
PAK_FILE="$DATA_DIR/$MOD_ID.pak"

# Verify file structure
echo "Verifying file structure..."
if [ ! -d "$DATA_DIR/Scripts/GearPicker" ]; then
    echo "WARN: GearPicker scripts directory not found at $DATA_DIR/Scripts/GearPicker"
    
    # Check if we have HelmetOffDialog directory instead and GearPicker.lua
    if [ -d "$DATA_DIR/Scripts/HelmetOffDialog" ] && [ -f "$DATA_DIR/Scripts/GearPicker/GearPicker.lua" ]; then
        echo "INFO: Found both HelmetOffDialog directory and GearPicker files"
        echo "This is expected during migration from HelmetOffDialog to GearPicker"
    fi
fi

# Verify critical files
CRITICAL_FILES=(
    "$DATA_DIR/Scripts/GearPicker/GearPicker.lua"
    "$DATA_DIR/Scripts/GearPicker/GearScan.lua"
    "$DATA_DIR/Scripts/Systems/GearPicker_Listeners.lua"
)

for file in "${CRITICAL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "WARNING: Critical file not found: $file"
        echo "The mod may not function correctly!"
    else
        echo "Verified: $file"
    fi
done

echo "Creating PAK file using Python script..."

# Use our Python script to create the PAK file
python3 "$SCRIPTS_DIR/pak_builder.py" --source "$DATA_DIR" --output "$PAK_FILE" --max-size 200

# Check if PAK file was created
if [ ! -f "$PAK_FILE" ]; then
    echo "ERROR: PAK file was not created by Python script"
    exit 1
fi

echo "PAK file created successfully"

# Clean up all non-PAK files from the Data directory
echo "Cleaning up temporary files..."
find "$DATA_DIR" -type f -not -name "*.pak" -delete
find "$DATA_DIR" -type d -empty -delete

# Create final zip file
ZIP_FILE="$BUILD_DIR/${MOD_ID}_${MOD_VERSION}.zip"
echo "Creating final ZIP file ($ZIP_FILE)..."

cd "$TEMP_DIR"
zip -r "$ZIP_FILE" "$MOD_ID"

# Verify zip content
echo "Verifying ZIP file contents..."
unzip -l "$ZIP_FILE"

echo ""
echo "============================================="
echo "Build complete!"
echo "Mod file created at: $ZIP_FILE"
echo "============================================="

# Check for deploy argument
if [ "$1" != "deploy" ]; then
    echo ""
    echo "All done!"
    exit 0
fi

echo ""
echo "Deploying mod to KCD2..."

# Default KCD2 paths for macOS - check multiple common locations
DEFAULT_KCD2_DIR="$HOME/Library/Application Support/Steam/steamapps/common/KingdomComeDeliverance2"
ALT_KCD2_DIR="/Applications/Steam/steamapps/common/KingdomComeDeliverance2"
ALT2_KCD2_DIR="$HOME/Documents/Steam/steamapps/common/KingdomComeDeliverance2"
ALT3_KCD2_DIR="$HOME/Steam/steamapps/common/KingdomComeDeliverance2"

# Determine KCD2 directory
KCD2_DIR="$DEFAULT_KCD2_DIR"

# If a path is explicitly provided, use it
if [ ! -z "$2" ]; then
    KCD2_DIR="$2"
    echo "Using user-provided game directory: [$KCD2_DIR]"
else
    # Auto-detection of installation directory
    echo "Attempting to auto-detect KCD2 installation directory..."
    
    if [ -d "$DEFAULT_KCD2_DIR" ]; then
        KCD2_DIR="$DEFAULT_KCD2_DIR"
        echo "Found KCD2 at default path: [$KCD2_DIR]"
    elif [ -d "$ALT_KCD2_DIR" ]; then
        KCD2_DIR="$ALT_KCD2_DIR"
        echo "Found KCD2 at alternative path 1: [$KCD2_DIR]"
    elif [ -d "$ALT2_KCD2_DIR" ]; then
        KCD2_DIR="$ALT2_KCD2_DIR"
        echo "Found KCD2 at alternative path 2: [$KCD2_DIR]"
    elif [ -d "$ALT3_KCD2_DIR" ]; then
        KCD2_DIR="$ALT3_KCD2_DIR"
        echo "Found KCD2 at alternative path 3: [$KCD2_DIR]"
    else
        echo "WARNING: Could not auto-detect KCD2 installation directory."
        echo "Using default directory: [$KCD2_DIR]"
        echo "If this is incorrect, please specify the path manually."
    fi
fi

echo "Debug: Final KCD2_DIR is set to: [$KCD2_DIR]"

echo "Checking for KCD2 at: $KCD2_DIR"
if [ ! -d "$KCD2_DIR" ]; then
    echo "ERROR: KCD2 directory not found at $KCD2_DIR"
    echo "Please specify the correct path as the second argument or ensure the default path is correct."
    echo "Example: ./build-macos-python.sh deploy \"$HOME/Games/KingdomComeDeliverance2\""
    exit 0
fi

echo "Deploying mod to KCD2 at $KCD2_DIR"

MODS_DIR="$KCD2_DIR/Mods"
echo "Setting up mods directory at: $MODS_DIR"
if [ ! -d "$MODS_DIR" ]; then
    mkdir -p "$MODS_DIR"
fi

# Clean existing mod files before deployment
MOD_DESTINATION="$MODS_DIR/$MOD_ID"

# Check for residual PAK files in other locations that might interfere
if [ -f "$MODS_DIR/Data/$MOD_ID.pak" ]; then
    echo "Removing leftover PAK file from incorrect location..."
    rm -f "$MODS_DIR/Data/$MOD_ID.pak"
fi

if [ -d "$MOD_DESTINATION" ]; then
    echo "Removing existing mod files from $MOD_DESTINATION..."
    rm -rf "$MOD_DESTINATION"
fi

# Additional cleanup to ensure PAK file isn't causing issues
MOD_PAK_FILE="$MOD_DESTINATION/Data/$MOD_ID.pak"
if [ -f "$MOD_PAK_FILE" ]; then
    echo "Removing existing PAK file from $MOD_PAK_FILE..."
    rm -f "$MOD_PAK_FILE"
fi

# Extract mod to mods folder
echo "Extracting new mod files..."
unzip -o "$ZIP_FILE" -d "$MODS_DIR"

# Verify deployment was successful
if [ ! -d "$MOD_DESTINATION" ]; then
    echo "ERROR: Mod directory was not created at $MOD_DESTINATION"
    exit 1
fi

if [ ! -f "$MOD_DESTINATION/Data/$MOD_ID.pak" ]; then
    echo "ERROR: PAK file was not deployed correctly to $MOD_DESTINATION/Data/$MOD_ID.pak"
    exit 1
fi

echo "Successfully deployed new version of $MOD_ID mod"

# Update mod_order.txt
echo "Updating mod_order.txt..."

# Explicitly use the mod_order.txt in the game directory provided by KCD2_DIR
MOD_ORDER_FILE="$KCD2_DIR/Mods/mod_order.txt"
echo "Checking mod_order.txt at: $MOD_ORDER_FILE"

if [ ! -f "$MOD_ORDER_FILE" ]; then
    echo "Writing new mod_order.txt file..."
    echo "$MOD_ID" > "$MOD_ORDER_FILE"
    echo "Created mod_order.txt and added $MOD_ID"
else
    # Check if file is empty
    if [ ! -s "$MOD_ORDER_FILE" ]; then
        echo "Empty mod_order.txt found, adding mod to file..."
        echo "$MOD_ID" > "$MOD_ORDER_FILE"
        echo "Added $MOD_ID to empty mod_order.txt"
    else
        # Check if mod is already in the file
        echo "Checking if mod is already in mod_order.txt..."
        if ! grep -q "^$MOD_ID$" "$MOD_ORDER_FILE"; then
            echo "Mod not found in mod_order.txt, adding now..."
            
            # Create a backup first
            cp "$MOD_ORDER_FILE" "${MOD_ORDER_FILE}.bak" 2>/dev/null
            
            # Remove trailing blank lines and add mod_id
            # Use a more compatible approach
            awk 'NF > 0' "$MOD_ORDER_FILE" > "${MOD_ORDER_FILE}.tmp"
            echo "" >> "${MOD_ORDER_FILE}.tmp"
            echo "$MOD_ID" >> "${MOD_ORDER_FILE}.tmp"
            mv "${MOD_ORDER_FILE}.tmp" "$MOD_ORDER_FILE"
            
            echo "Added $MOD_ID to mod_order.txt"
        else
            echo "Mod already exists in mod_order.txt"
        fi
    fi
fi

echo ""
echo "============================================="
echo "Mod deployed successfully to $MOD_DESTINATION"
echo "============================================="

echo ""
echo "All done!"
exit 0