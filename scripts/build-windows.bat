@echo off
setlocal EnableDelayedExpansion

REM Updated build script for Windows
REM This builds the GearPicker mod into a PAK file compatible with KCD2

REM Set variables for paths
set "PROJECT_ROOT=%~dp0.."
set "TARGET=main"
set "MOD_SRC_DIR=%PROJECT_ROOT%\src\%TARGET%"
set "BUILD_DIR=%PROJECT_ROOT%\build_windows"
set "TEMP_DIR=%BUILD_DIR%\temp"

echo =============================================
echo Building GearPicker Mod for KCD2...
echo =============================================

REM Check for 7-Zip installation
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
mkdir "%TEMP_DIR%\Data\Scripts"

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
xcopy /E /I /Y "%MOD_SRC_DIR%\Data" "%TEMP_DIR%\Data"

REM Create Data directory and PAK file paths
set "DATA_DIR=%TEMP_DIR%\Data"
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

echo Creating PAK file ("%PAK_FILE%")...

REM Get current directory to return to it later
pushd "%DATA_DIR%"

REM Create a list of files to pack (excluding any existing PAK files)
echo Creating file list...
dir /s /b /a-d | findstr /v "\.pak$" > filelist.txt

REM Count total files to pack
for /f %%A in ('type filelist.txt ^| find /c /v ""') do set "TOTAL_FILES=%%A"
echo Packing %TOTAL_FILES% files into PAK...

REM Use standard zip with options -r -9 -X to match the archived mod
echo Creating the PAK file using compatible zip format...
REM Note: We use 7-Zip but with parameters that create compatible zip format
"%SEVENZIP_PATH%" a -tzip -mm=Deflate -mfb=128 -mpass=10 -mx=9 "%MOD_ID%.pak" @filelist.txt

REM Delete the temporary file list
del filelist.txt

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
    rmdir /s /q "%%d" 2>nul
)

REM Create final mod structure
mkdir "%TEMP_DIR%\%MOD_ID%"
move "%DATA_DIR%" "%TEMP_DIR%\%MOD_ID%\"
copy "%MOD_SRC_DIR%\mod.manifest" "%TEMP_DIR%\%MOD_ID%\"

echo Copied mod.manifest to mod package

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

REM Default KCD2 path
set "DEFAULT_KCD2_DIR=C:\Program Files (x86)\Steam\steamapps\common\KingdomComeDeliverance2"

REM Determine KCD2 directory
set "KCD2_DIR=%DEFAULT_KCD2_DIR%"
if not "%ARG2%"=="" set "KCD2_DIR=%ARG2%"

echo DEBUG: KCD2_DIR is set to: ["%KCD2_DIR%"]

echo Checking for KCD2 at: "%KCD2_DIR%"
if not exist "%KCD2_DIR%\" (
    echo ERROR: KCD2 directory not found at "%KCD2_DIR%"
    echo Please specify the correct path as the second argument or ensure the default path is correct.
    echo Example: build-windows.bat deploy "D:\Steam\steamapps\common\KingdomComeDeliverance2"
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
set "MOD_ORDER_FILE=%MODS_DIR%\mod_order.txt"
echo Checking mod_order.txt at: "%MOD_ORDER_FILE%"
if not exist "%MOD_ORDER_FILE%" (
    echo Writing new mod_order.txt file...
    echo %MOD_ID%> "%MOD_ORDER_FILE%"
    echo Created mod_order.txt and added %MOD_ID%
    goto :after_mod_order_update
)

REM Check if mod is already in the file
echo Checking if mod is already in mod_order.txt...

REM Use findstr with proper options to find exact matches
findstr /x /c:"%MOD_ID%" "%MOD_ORDER_FILE%" >nul
if %ERRORLEVEL% neq 0 (
    REM Ensure file has proper ending
    setlocal EnableDelayedExpansion
    
    REM Create a temporary file for processing
    set "TEMP_ORDER_FILE=%TEMP%\temp_mod_order.txt"
    
    REM Remove any empty lines at the end of file
    type "%MOD_ORDER_FILE%" | findstr /v /r "^$" > "%TEMP_ORDER_FILE%"
    
    REM Copy back to original, ensuring a single newline at end
    copy /y "%TEMP_ORDER_FILE%" "%MOD_ORDER_FILE%" >nul
    
    REM Now append mod ID with a single newline
    echo.>> "%MOD_ORDER_FILE%"
    echo %MOD_ID%>> "%MOD_ORDER_FILE%"
    
    REM Clean up temp file
    del "%TEMP_ORDER_FILE%"
    
    echo Added %MOD_ID% to mod_order.txt
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