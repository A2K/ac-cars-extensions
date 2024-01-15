@echo off
setlocal enabledelayedexpansion

set "searchFiles=bmw_m3_e30.kn5 bmw_1m.kn5 bmw_m3_e92.kn5 bmw_m4.kn5 bmw_m235i_racing.kn5 bmw_m3_e30_grA.kn5 nissan_gtr.kn5"

set "bmw_m3_e30.kn5=a2k_bmw_e30_se"
set "bmw_1m.kn5=a2k_bmw_e82_2011_1m"
set "bmw_m3_e92.kn5=a2k_bmw_e92_2008_m3"
set "bmw_m4.kn5=a2k_bmw_f82_2015_m4"
set "bmw_m235i_racing.kn5=a2k_bmw_m235i_racing"
set "bmw_m3_e30_grA.kn5=a2k_dtm1992_bmw_e30_m3_evo3"
set "nissan_gtr.kn5=a2k_nissan_r35_2014_gtr_nismo"

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
    exit 1
)


echo Assetto Corsa root folder: %InstallLocation%

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
                echo robocopy %~dp0assettocorsa\content\cars\!%%f!\extension %basePath%\%%c\extension /E
            ) else (
                echo Skipping !carname!
            )
        )
    )
)

endlocal