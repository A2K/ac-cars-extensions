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

robocopy "%~dp0assettocorsa\extension\textures\common\a2k" "%WORKDIR%\assettocorsa\mods\BMW Extensions\extension\textures\common\a2k" /E

@REM mkdir "%WORKDIR%assettocorsa\content\cars"

set "basePath=%~dp0assettocorsa\content\cars"

for %%c in (%SUPPORTED_CARS%) do (
    for %%f in (%searchFiles%) do (
        set "filePath=%basePath%\%%c\%%f"
        if exist "!filePath!" (
            robocopy "%~dp0assettocorsa\content\cars\!%%f!\extension" "%WORKDIR%assettocorsa\mods\BMW Extensions\content\cars\%%c\extension" /E /XF "*.fbx" /XF "*.fbx.ini"
        )
    )
)

echo BMW Extensions > "%WORKDIR%\assettocorsa\mods\BMW Extensions\name.jsgme
echo Various improvements for stock BMWs > "%WORKDIR%\assettocorsa\mods\BMW Extensions\Description.jsgme
echo 1.3 > "%WORKDIR%\assettocorsa\mods\BMW Extensions\version.jsgme

SET CURRENTDIR="%cd%"

cd %WORKDIR%

set "ARTIFACT=%~dp0bmw-extensions.zip"
del "%ARTIFACT%"

7z a "%ARTIFACT%" assettocorsa

cd %CURRENTDIR%

RMDIR /s /q %WORKDIR%

echo
echo %ARTIFACT%
echo
