@echo off
setlocal EnableDelayedExpansion

REM Updated build script for Windows using Python PAK builder
REM This builds the GearPicker mod into a PAK file compatible with KCD2

REM Set variables for paths
set "PROJECT_ROOT=%~dp0.."
set "TARGET=main"
set "MOD_SRC_DIR=%PROJECT_ROOT%\src\%TARGET%"
set "BUILD_DIR=%PROJECT_ROOT%\build_windows"
set "TEMP_DIR=%BUILD_DIR%\temp"
set "SCRIPTS_DIR=%PROJECT_ROOT%\scripts"

echo =============================================
echo Building GearPicker Mod for KCD2...
echo =============================================

REM Check for Python installation
python --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.6+ from https://www.python.org/downloads/
    exit /b 1
)

REM Check for 7-Zip installation (still needed for final ZIP and deploy)
set "SEVENZIP_PATH=C:\Program Files\7-Zip\7z.exe"
if not exist "%SEVENZIP_PATH%" (
    echo ERROR: 7-Zip not found at "%SEVENZIP_PATH%"
    echo Please install 7-Zip from https://www.7-zip.org/
    echo or update this script with the correct path
    exit /b 1
)

REM Create clean build directory
echo Cleaning build directories...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
mkdir "%TEMP_DIR%\gear_picker"
mkdir "%TEMP_DIR%\gear_picker\Data"

REM Read manifest file to get mod details
set "MANIFEST_FILE=%MOD_SRC_DIR%\mod.manifest"
if not exist "%MANIFEST_FILE%" (
    echo ERROR: Manifest file not found at "%MANIFEST_FILE%"
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
xcopy /E /I /Y "%MOD_SRC_DIR%\Data" "%TEMP_DIR%\%MOD_ID%\Data"
copy "%MOD_SRC_DIR%\mod.manifest" "%TEMP_DIR%\%MOD_ID%\"
echo Copied mod.manifest to build directory

REM Create Data directory and PAK file paths
set "DATA_DIR=%TEMP_DIR%\%MOD_ID%\Data"
set "PAK_FILE=%DATA_DIR%\%MOD_ID%.pak"

echo Verifying file structure...
if not exist "%DATA_DIR%\Scripts\GearPicker\" (
    echo WARN: GearPicker scripts directory not found at "%DATA_DIR%\Scripts\GearPicker"
    
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

echo Creating PAK file using Python script...

REM Use our Python script to create the PAK file
python "%SCRIPTS_DIR%\pak_builder.py" --source "%DATA_DIR%" --output "%PAK_FILE%" --max-size 200

REM Check if PAK file was created
if not exist "%PAK_FILE%" (
    echo ERROR: PAK file was not created by Python script
    exit /b 1
)

echo PAK file created successfully

REM Clean up all non-PAK files from the Data directory
echo Cleaning up temporary files...
for /r "%DATA_DIR%" %%f in (*) do (
    if not "%%~xf"==".pak" del "%%f"
)
for /d /r "%DATA_DIR%" %%d in (*) do (
    rmdir /s /q "%%d" 2>nul
)

REM Create final zip file
set "ZIP_FILE=%BUILD_DIR%\%MOD_ID%_%MOD_VERSION%.zip"
echo Creating final ZIP file ("%ZIP_FILE%")...

pushd "%TEMP_DIR%"
REM Use the same zip parameters that match the archived mod
echo Creating the final ZIP file...
"%SEVENZIP_PATH%" a -tzip -mm=Deflate -mfb=128 -mpass=10 -mx=9 "%ZIP_FILE%" "%MOD_ID%"

REM Verify zip content
echo Verifying ZIP file contents...
"%SEVENZIP_PATH%" l "%ZIP_FILE%"
popd

echo.
echo =============================================
echo Build complete!
echo Mod file created at: "%ZIP_FILE%"
echo =============================================

REM Check for deploy argument
if /i not "%1"=="deploy" goto :end

echo.
echo Deploying mod to KCD2...

echo DEBUG: Script argument 2 is: [%2]
set "ARG2=%~2"
echo DEBUG: ARG2 (after %~2) is: [%ARG2%]

REM Default KCD2 paths - check multiple common locations
set "DEFAULT_KCD2_DIR=C:\Program Files (x86)\Steam\steamapps\common\KingdomComeDeliverance2"
set "ALT_KCD2_DIR=D:\Steam\steamapps\common\KingdomComeDeliverance2"
set "ALT2_KCD2_DIR=C:\Program Files\Steam\steamapps\common\KingdomComeDeliverance2"
set "ALT3_KCD2_DIR=E:\Steam\steamapps\common\KingdomComeDeliverance2"

REM Determine KCD2 directory
set "KCD2_DIR=%DEFAULT_KCD2_DIR%"

REM If a path is explicitly provided, use it
if not "%ARG2%"=="" (
    set "KCD2_DIR=%ARG2%"
    echo Using user-provided game directory: ["%KCD2_DIR%"]
) else (
    REM Auto-detection of installation directory
    echo Attempting to auto-detect KCD2 installation directory...
    
    if exist "%DEFAULT_KCD2_DIR%" (
        set "KCD2_DIR=%DEFAULT_KCD2_DIR%"
        echo Found KCD2 at default path: ["%KCD2_DIR%"]
    ) else if exist "%ALT_KCD2_DIR%" (
        set "KCD2_DIR=%ALT_KCD2_DIR%"
        echo Found KCD2 at alternative path 1: ["%KCD2_DIR%"]
    ) else if exist "%ALT2_KCD2_DIR%" (
        set "KCD2_DIR=%ALT2_KCD2_DIR%"
        echo Found KCD2 at alternative path 2: ["%KCD2_DIR%"]
    ) else if exist "%ALT3_KCD2_DIR%" (
        set "KCD2_DIR=%ALT3_KCD2_DIR%"
        echo Found KCD2 at alternative path 3: ["%KCD2_DIR%"]
    ) else (
        echo WARNING: Could not auto-detect KCD2 installation directory.
        echo Using default directory: ["%KCD2_DIR%"]
        echo If this is incorrect, please specify the path manually.
    )
)

echo Debug: Final KCD2_DIR is set to: ["%KCD2_DIR%"]

echo Checking for KCD2 at: "%KCD2_DIR%"
if not exist "%KCD2_DIR%\" (
    echo ERROR: KCD2 directory not found at "%KCD2_DIR%"
    echo Please specify the correct path as the second argument or ensure the default path is correct.
    echo Example: build-windows-python.bat deploy "D:\Steam\steamapps\common\KingdomComeDeliverance2"
    goto :end
)

echo Deploying mod to KCD2 at "%KCD2_DIR%"

set "MODS_DIR=%KCD2_DIR%\Mods"
echo Setting up mods directory at: "%MODS_DIR%"
if not exist "%MODS_DIR%" mkdir "%MODS_DIR%"

REM Stop the game process if it's running
echo Checking if KCD2 is running...
taskkill /F /IM "KingdomCome.exe" 2>nul
if %ERRORLEVEL% EQU 0 (
    echo KCD2 was running and has been closed.
    timeout /t 2 > nul
) else (
    echo KCD2 is not running or could not be closed.
)

REM Clean existing mod files before deployment - thorough cleanup to prevent issues
set "MOD_DESTINATION=%MODS_DIR%\%MOD_ID%"

REM Check for residual PAK files in other locations that might interfere
if exist "%MODS_DIR%\Data\%MOD_ID%.pak" (
    echo Removing leftover PAK file from incorrect location...
    del /F /Q "%MODS_DIR%\Data\%MOD_ID%.pak"
)

if exist "%MOD_DESTINATION%" (
    echo Removing existing mod files from "%MOD_DESTINATION%"...
    rmdir /s /q "%MOD_DESTINATION%"
    
    REM Verify the directory was actually deleted
    if exist "%MOD_DESTINATION%" (
        echo WARNING: Could not fully remove "%MOD_DESTINATION%". Trying again...
        timeout /t 1 > nul
        rmdir /s /q "%MOD_DESTINATION%"
    )
)

REM Additional cleanup to ensure PAK file isn't causing issues
set "MOD_PAK_FILE=%MOD_DESTINATION%\Data\%MOD_ID%.pak"
if exist "%MOD_PAK_FILE%" (
    echo Removing existing PAK file from "%MOD_PAK_FILE%"...
    del /F /Q "%MOD_PAK_FILE%"
)

REM Extract mod to mods folder
echo Extracting new mod files...
"%SEVENZIP_PATH%" x -o"%MODS_DIR%" -y "%ZIP_FILE%"

REM Verify deployment was successful
if not exist "%MOD_DESTINATION%" (
    echo ERROR: Mod directory was not created at "%MOD_DESTINATION%"
    exit /b 1
)

if not exist "%MOD_DESTINATION%\Data\%MOD_ID%.pak" (
    echo ERROR: PAK file was not deployed correctly to "%MOD_DESTINATION%\Data\%MOD_ID%.pak"
    exit /b 1
)

echo Successfully deployed new version of %MOD_ID% mod

REM Update mod_order.txt
echo "Updating mod_order.txt..."

REM Explicitly use the mod_order.txt in the game directory provided by KCD2_DIR
set "MOD_ORDER_FILE=%KCD2_DIR%\Mods\mod_order.txt"
echo Checking mod_order.txt at: "%MOD_ORDER_FILE%"

REM Make sure the Mods directory exists
if not exist "%KCD2_DIR%\Mods" (
    echo "Creating Mods directory at: %KCD2_DIR%\Mods"
    mkdir "%KCD2_DIR%\Mods" 2>nul
    if errorlevel 1 (
        echo "WARNING: Could not create Mods directory. Check permissions."
        echo "Skipping mod_order.txt update."
        goto :after_mod_order_update
    )
)

if not exist "%MOD_ORDER_FILE%" (
    echo Writing new mod_order.txt file...
    echo %MOD_ID%> "%MOD_ORDER_FILE%"
    echo Created mod_order.txt and added %MOD_ID%
    goto :after_mod_order_update
)

REM Check if mod is already in the file - Ensure the file exists first
echo Checking if mod is already in mod_order.txt...

REM Ensure the file exists and is accessible
if not exist "%MOD_ORDER_FILE%" (
    echo "WARNING: mod_order.txt not found at %MOD_ORDER_FILE% - creating new file"
    echo %MOD_ID%> "%MOD_ORDER_FILE%"
    echo Created new mod_order.txt and added %MOD_ID%
    goto :after_mod_order_update
)

REM Save current error level before the findstr command
set "CURRENT_ERROR_LEVEL=%ERRORLEVEL%"

REM Use findstr with proper options to find exact matches
findstr /x /c:"%MOD_ID%" "%MOD_ORDER_FILE%" >nul 2>&1
set "FINDSTR_ERROR_LEVEL=%ERRORLEVEL%"

REM Check if file is empty
for %%A in ("%MOD_ORDER_FILE%") do set "FILE_SIZE=%%~zA"
if %FILE_SIZE% EQU 0 (
    echo "Empty mod_order.txt found, adding mod to file..."
    echo %MOD_ID%> "%MOD_ORDER_FILE%"
    echo Added %MOD_ID% to empty mod_order.txt
    goto :after_mod_order_update
)

if %FINDSTR_ERROR_LEVEL% neq 0 (
    REM We need to add the mod to the file
    echo "Mod not found in mod_order.txt, adding now..."
    
    REM Create a temporary file for processing
    set "TEMP_ORDER_FILE=%TEMP%\temp_mod_order.txt"
    
    REM Remove any empty lines at the end of file (safely)
    type "%MOD_ORDER_FILE%" > "%TEMP_ORDER_FILE%" 2>nul
    if exist "%TEMP_ORDER_FILE%" (
        REM Now append mod ID with a single newline
        echo.>> "%TEMP_ORDER_FILE%"
        echo %MOD_ID%>> "%TEMP_ORDER_FILE%"
        
        REM Copy back to original (create backup first in case something goes wrong)
        copy "%MOD_ORDER_FILE%" "%MOD_ORDER_FILE%.bak" >nul 2>&1
        copy /y "%TEMP_ORDER_FILE%" "%MOD_ORDER_FILE%" >nul 2>&1
        
        REM Clean up temp file
        del "%TEMP_ORDER_FILE%" >nul 2>&1
        
        echo Added %MOD_ID% to mod_order.txt
    ) else (
        echo "WARNING: Could not create temp file. Manual intervention required."
        echo %MOD_ID%>> "%MOD_ORDER_FILE%"
    )
) else (
    echo Mod already exists in mod_order.txt
)
:after_mod_order_update

echo.
echo =============================================
echo Mod deployed successfully to "%MOD_DESTINATION%"
echo =============================================

:end
echo.
echo All done!
exit /b 0