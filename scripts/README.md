# KCD2 Gear Picker Build Scripts

This directory contains build scripts for creating the KCD2 Gear Picker mod package.

## Python PAK Builder

The new Python-based build system uses `pak_builder.py`, which is a simplified version of the KCD-PAK-Builder tool. It offers these advantages:

- Cross-platform compatibility (works on Windows, macOS, Linux)
- No dependency on 7-Zip for the PAK creation (only needed for final ZIP)
- Better performance and flexibility

## Available Scripts

### Windows

1. **build-windows.bat** - Original build script using 7-Zip for PAK creation
2. **build-windows-python.bat** - New build script using Python PAK builder

Usage:
```
.\build-windows-python.bat [deploy] [KCD2_PATH]
```

Examples:
- Build only: `.\build-windows-python.bat`
- Build and deploy: `.\build-windows-python.bat deploy`
- Build and deploy to custom location: `.\build-windows-python.bat deploy "D:\Games\KCD2"`

### macOS

1. **build-macos.sh** - Original build script using zip
2. **build-macos-python.sh** - New build script using Python PAK builder

Usage:
```
./build-macos-python.sh [deploy] [KCD2_PATH]
```

Examples:
- Build only: `./build-macos-python.sh`
- Build and deploy: `./build-macos-python.sh deploy`
- Build and deploy to custom location: `./build-macos-python.sh deploy "~/Games/KCD2"`

## Python PAK Builder Options

The `pak_builder.py` script can be used directly with these options:

```
python pak_builder.py --source SOURCE_DIR --output OUTPUT_PAK [options]
```

Options:
- `--source`: Source directory to pack (required)
- `--output`: Output PAK file path (required)
- `--max-size`: Maximum PAK size in MB (default: 500)
- `--include-paks`: Include existing PAK files (by default, nested PAK files are ignored)

## Requirements

- Python 3.6 or higher
- For Windows deployment: 7-Zip (only for creating the final ZIP file and deployment)
- For macOS deployment: Standard zip/unzip tools (included with macOS)