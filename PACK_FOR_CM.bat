@echo off
setlocal enabledelayedexpansion

set "SUPPORTED_CARS=bmw_1m bmw_1m_s3 bmw_m3_e30 bmw_m3_e30_drift bmw_m3_e30_dtm bmw_m3_e30_dtm_mod bmw_m3_e30_gra bmw_m3_e30_s1 bmw_m3_e92 bmw_m3_e92_drift bmw_m3_e92_s1 bmw_z4 bmw_z4_drift bmw_z4_s1 ks_bmw_m235i_racing ks_bmw_m4 ks_bmw_m4_akrapovic"

set "searchFiles=bmw_m3_e30.kn5 bmw_1m.kn5 bmw_m3_e92.kn5 bmw_m4.kn5 bmw_m235i_racing.kn5 bmw_m3_e30_grA.kn5 bmw_z4.kn5"

set "bmw_m3_e30.kn5=a2k_bmw_e30_se"
set "bmw_1m.kn5=a2k_bmw_e82_2011_1m"
set "bmw_m3_e92.kn5=a2k_bmw_e92_2008_m3"
set "bmw_m4.kn5=a2k_bmw_f82_2015_m4"
set "bmw_m235i_racing.kn5=a2k_bmw_m235i_racing"
set "bmw_m3_e30_grA.kn5=a2k_dtm1992_bmw_e30_m3_evo3"
set "nissan_gtr.kn5=a2k_nissan_r35_2014_gtr_nismo"
set "bmw_z4.kn5=a2k_bmw_z4"

rem Use reg query to get the value of the specified registry key
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App 244210" /v "InstallLocation" ^| find "InstallLocation"') do (
    set "InstallLocation=%%b"
)

if "!InstallLocation!" == "" (
    echo Could not auto-detect install path

    if "!InstallLocation!" == "" (
        echo.
        echo Where is your Assetto Corsa root folder?

        for /f "tokens=* USEBACKQ" %%a in (`SelectPath.bat`) do (
            set InstallLocation=%%a
        )
    )

)

if "!InstallLocation!" == "" (
    echo Assetto Corsa not found
    pause
    exit 1
)


echo Assetto Corsa root folder: %InstallLocation%

cd /D %TEMP%

set "WORKDIR=%TEMP%\bmw-ext-%RANDOM%\"

@REM mkdir %WORKDIR%\assettocorsa\extension\textures\common\a2k

robocopy "%~dp0assettocorsa\extension\textures\common\a2k" "%WORKDIR%\assettocorsa\extension\textures\common\a2k" /E

@REM mkdir "%WORKDIR%assettocorsa\content\cars"

set "basePath=%~dp0assettocorsa\content\cars"

for %%c in (%SUPPORTED_CARS%) do (
    @REM echo "%WORKDIR%assettocorsa\content\cars\%%c\extension"
    @REM mkdir "%WORKDIR%assettocorsa\content\cars\%%c\extension"

    for %%f in (%searchFiles%) do (
        set "filePath=%basePath%\%%c\%%f"
        if exist "!filePath!" (
            @REM echo "%~dp0assettocorsa\content\cars\!%%f!\extension"
            robocopy "%~dp0assettocorsa\content\cars\!%%f!\extension" "%WORKDIR%assettocorsa\content\cars\%%c\extension" /E /XF "*.fbx" /XF "*.fbx.ini"
        )
    )
)

SET CURRENTDIR="%cd%"

cd %WORKDIR%

set "ARTIFACT=%~dp0bmw-extensions.zip"
del "%ARTIFACT%"

7z a "%ARTIFACT%" assettocorsa

echo "%ARTIFACT%"

cd %CURRENTDIR%

RMDIR /s /q %WORKDIR%

exit 0

echo Installing shared content to %InstallLocation%\extension\textures\common

set "installAll="

set "basePath=%InstallLocation%\content\cars"

echo Scanning cars in %basepath%...
set detectedCars=
for /d %%i in (%basePath%\*) do (
    for %%a in (%%i) do for %%b in ("%%~dpa\.") do set "carname=%%~nxa"
    if /i "!carname:~0,4!" NEQ "a2k_" (
        for %%f in (%searchFiles%) do (
            set "filePath=%%i\%%f"
            set "doInstall="
            if exist "!filePath!" (
                set "detectedCars=!detectedCars! !carname!"
            )
        )
    )
)

echo Found compatible cars:%detectedCars%

for %%c in (%detectedCars%) do (
    set carname=%%c
    for %%f in (%searchFiles%) do (
        set "filePath=%basePath%\%%c\%%f"
        set "doInstall="
        if exist "!filePath!" (
            if !installAll! == 1 (
                set doInstall=Y
            ) else (
                set /p "doInstall=Install extension !%%f! for car !carname! [Y/n/A]?: "
            )

            if "!doInstall!" == "A" (
                set installAll=1
                set doInstall=Y
            )
            if "!doInstall!" == "Y" (
                echo %%c !%%f!
                robocopy "%~dp0assettocorsa\content\cars\!%%f!\extension" "%basePath%\%%c\extension" /E
            ) else (
                echo Skipping !carname!
            )
        )
    )
)

endlocal

echo All finished!

pause