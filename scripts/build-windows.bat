@echo off
setlocal enabledelayedexpansion

REM GearPicker Mod build script for Windows
REM This script builds the mod and optionally deploys it to KCD2

echo =============================================
echo Building GearPicker Mod for KCD2...
echo =============================================

REM Set variables for paths
set "PROJECT_ROOT=%~dp0.."
set "TARGET=main"
set "MOD_SRC_DIR=%PROJECT_ROOT%\src\%TARGET%"
set "BUILD_DIR=%PROJECT_ROOT%\build_windows"
set "TEMP_DIR=%BUILD_DIR%\temp"

REM Check for 7-Zip installation
set "SEVENZIP_PATH=C:\Program Files\7-Zip\7z.exe"
if not exist "%SEVENZIP_PATH%" (
    echo ERROR: 7-Zip not found at %SEVENZIP_PATH%
    echo Please install 7-Zip from https://www.7-zip.org/
    echo or update this script with the correct path
    exit /b 1
)

REM Create clean build directory
echo Cleaning build directories...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
mkdir "%TEMP_DIR%\Data\Scripts"

REM Read manifest file to get mod details
set "MANIFEST_FILE=%MOD_SRC_DIR%\mod.manifest"
if not exist "%MANIFEST_FILE%" (
    echo ERROR: Manifest file not found at %MANIFEST_FILE%
    exit /b 1
)

REM Create a temporary file with the manifest contents for easier parsing
type "%MANIFEST_FILE%" > "%TEMP_DIR%\manifest_temp.txt"

REM Hard-code the values as a fallback
set "MOD_ID=gear_picker"
set "MOD_VERSION=1.1.0"
set "MOD_NAME=Gear Picker"

REM Try to extract values from manifest (simpler approach)
for /f "tokens=3 delims=<>" %%a in ('findstr /C:"<modid>" "%TEMP_DIR%\manifest_temp.txt"') do set "MOD_ID=%%a"
for /f "tokens=3 delims=<>" %%a in ('findstr /C:"<version>" "%TEMP_DIR%\manifest_temp.txt"') do set "MOD_VERSION=%%a"
for /f "tokens=3 delims=<>" %%a in ('findstr /C:"<n>" "%TEMP_DIR%\manifest_temp.txt"') do set "MOD_NAME=%%a"

REM Clean up the temporary file
del "%TEMP_DIR%\manifest_temp.txt"

echo Building mod: %MOD_NAME% (%MOD_ID%) version %MOD_VERSION%

REM Copy all files from source to build dir
echo Copying source files...
xcopy /E /I /Y "%MOD_SRC_DIR%\Data" "%TEMP_DIR%\Data"

REM Create Data directory and PAK file paths
set "DATA_DIR=%TEMP_DIR%\Data"
set "PAK_FILE=%DATA_DIR%\%MOD_ID%.pak"

echo Verifying file structure...
if not exist "%DATA_DIR%\Scripts\GearPicker\" (
    echo WARN: GearPicker scripts directory not found at %DATA_DIR%\Scripts\GearPicker
    
    REM Check if we have HelmetOffDialog directory instead and GearPicker.lua
    if exist "%DATA_DIR%\Scripts\HelmetOffDialog\" (
        if exist "%DATA_DIR%\Scripts\GearPicker\GearPicker.lua" (
            echo INFO: Found both HelmetOffDialog directory and GearPicker files
            echo This is expected during migration from HelmetOffDialog to GearPicker
        )
    )
)

REM Verify critical files
set "CRITICAL_FILES=%DATA_DIR%\Scripts\GearPicker\GearPicker.lua %DATA_DIR%\Scripts\GearPicker\GearScan.lua %DATA_DIR%\Scripts\Systems\GearPicker_Listeners.lua"
for %%f in (%CRITICAL_FILES%) do (
    if not exist "%%f" (
        echo WARNING: Critical file not found: %%f
        echo The mod may not function correctly!
    ) else (
        echo Verified: %%f
    )
)

echo Creating PAK file (%PAK_FILE%)...

REM Get current directory to return to it later
pushd "%DATA_DIR%"

REM Create the PAK file using 7-Zip - fixed wildcard issue
"%SEVENZIP_PATH%" a -tzip -mx9 "%MOD_ID%.pak" *
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to create PAK file
    popd
    exit /b 1
)

REM Return to previous directory
popd

REM Check if PAK file was created
if not exist "%PAK_FILE%" (
    echo ERROR: PAK file was not created
    exit /b 1
)

echo PAK file created successfully

REM Clean up all non-PAK files from the Data directory
echo Cleaning up temporary files...
for /r "%DATA_DIR%" %%f in (*) do (
    if not "%%~xf"==".pak" del "%%f"
)
for /d /r "%DATA_DIR%" %%d in (*) do (
    rmdir "%%d" 2>nul
)

REM Create final mod structure
mkdir "%TEMP_DIR%\%MOD_ID%"
move "%DATA_DIR%" "%TEMP_DIR%\%MOD_ID%\"
copy "%MOD_SRC_DIR%\mod.manifest" "%TEMP_DIR%\%MOD_ID%\"
copy "%PROJECT_ROOT%\src\modding_eula.txt" "%TEMP_DIR%\%MOD_ID%\"

echo Copied mod.manifest and modding_eula.txt to mod package

REM Create final zip file
set "ZIP_FILE=%BUILD_DIR%\%MOD_ID%_%MOD_VERSION%.zip"
echo Creating final ZIP file (%ZIP_FILE%)...

pushd "%TEMP_DIR%"
"%SEVENZIP_PATH%" a -tzip -mx9 "%ZIP_FILE%" "%MOD_ID%"
popd

echo Verifying ZIP file contents...
"%SEVENZIP_PATH%" l "%ZIP_FILE%"

echo Build complete! Mod file created at: %ZIP_FILE%

REM Deploy option
if "%1"=="deploy" (
    echo Deploying mod to KCD2...
    
    REM Default KCD2 path
    set "KCD2_DIR=C:\Program Files (x86)\Steam\steamapps\common\KingdomComeDeliverance2"
    
    REM Allow custom path as second argument
    if not "%2"=="" (
        set "KCD2_DIR=%~2"
    )
    
    echo Checking for KCD2 at: "%KCD2_DIR%"
    if not exist "%KCD2_DIR%" (
        echo ERROR: KCD2 directory not found at "%KCD2_DIR%"
        echo Please specify the correct path as the second argument.
        echo Example: build-windows.bat deploy "D:\Steam\steamapps\common\KingdomComeDeliverance2"
        exit /b 1
    )
    
    echo Deploying mod to KCD2 at "%KCD2_DIR%"
    
    set "MODS_DIR=%KCD2_DIR%\Mods"
    echo Setting up mods directory at: "%MODS_DIR%"
    if not exist "%MODS_DIR%" mkdir "%MODS_DIR%"
    
    REM Clean existing mod files before deployment
    set "MOD_DESTINATION=%MODS_DIR%\%MOD_ID%"
    if exist "%MOD_DESTINATION%" (
        echo Removing existing mod files from %MOD_DESTINATION%...
        rmdir /s /q "%MOD_DESTINATION%"
    )
    
    REM Extract mod to mods folder
    echo Extracting new mod files...
    "%SEVENZIP_PATH%" x -o"%MODS_DIR%" -y "%ZIP_FILE%"
    
    REM Update mod_order.txt
    set "MOD_ORDER_FILE=%MODS_DIR%\mod_order.txt"
    echo Checking mod_order.txt at: "%MOD_ORDER_FILE%"
    if not exist "%MOD_ORDER_FILE%" (
        echo Writing new mod_order.txt file...
        echo %MOD_ID%> "%MOD_ORDER_FILE%"
        echo Created mod_order.txt and added %MOD_ID%
    ) else (
        echo Checking if mod is already in mod_order.txt...
        findstr /c:"%MOD_ID%" "%MOD_ORDER_FILE%" >nul
        if !ERRORLEVEL! neq 0 (
            echo Appending mod ID to mod_order.txt...
            echo %MOD_ID%>> "%MOD_ORDER_FILE%"
            echo Added %MOD_ID% to mod_order.txt
        ) else (
            echo Mod already exists in mod_order.txt
        )
    )
    
    echo =============================================
    echo Mod deployed successfully to "%MOD_DESTINATION%"
    echo =============================================
)

echo All done!
exit /b 0