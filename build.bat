@echo off
rem ============================================================================
rem  build.bat - builds the projects in this merged repository (Windows).
rem
rem    build.bat                 interactive menu (also what double-click runs)
rem    build.bat sm64            build sm64coopdx   -> sm64coopdx\build\us_pc\sm64coopdx.exe
rem    build.bat xbox360         build the Xbox 360 decompilation
rem    build.bat all             build both
rem    build.bat xbox360 Debug   second argument picks the CMake config (default Release)
rem
rem  See BUILDING.md for the prerequisites of each project.
rem ============================================================================
setlocal EnableExtensions
title Merged repo builder
cd /d "%~dp0"

set "INTERACTIVE=0"
set "EXITCODE=0"
set "TARGET=%~1"
set "CONFIG=%~2"
if "%CONFIG%"=="" set "CONFIG=Release"
set "RESULT_SM64=skipped"
set "RESULT_XBOX=skipped"

if "%TARGET%"=="" set "INTERACTIVE=1"
if "%TARGET%"=="" goto :menu
goto :dispatch

:menu
echo.
echo  ==================================================
echo    Merged repo builder
echo  ==================================================
echo    [1] sm64coopdx          Windows exe, needs MSYS2
echo    [2] Minecraft Xbox 360  needs the Xbox 360 XDK
echo    [3] Both
echo    [Q] Quit
echo.
choice /c 123Q /n /m "Choose an option: "
if errorlevel 4 goto :finish
if errorlevel 3 set "TARGET=all" & goto :dispatch
if errorlevel 2 set "TARGET=xbox360" & goto :dispatch
if errorlevel 1 set "TARGET=sm64" & goto :dispatch
goto :finish

:dispatch
if /i "%TARGET%"=="sm64"    goto :do_sm64
if /i "%TARGET%"=="xbox360" goto :do_xbox
if /i "%TARGET%"=="all"     goto :do_sm64
if /i "%TARGET%"=="help"    goto :usage
if /i "%TARGET%"=="/?"      goto :usage
echo Unknown target: %TARGET%
set "EXITCODE=2"
goto :usage

:usage
echo.
echo Usage: build.bat [sm64 ^| xbox360 ^| all] [Release ^| Debug]
echo        build.bat with no arguments opens a menu.
goto :finish

rem ----------------------------------------------------------------------------
rem  sm64coopdx (MSYS2 / MinGW64 + make)
rem ----------------------------------------------------------------------------
:do_sm64
echo.
echo === sm64coopdx ===
set "MSYS2_DIR="
if defined MSYS2_ROOT if exist "%MSYS2_ROOT%\usr\bin\bash.exe" set "MSYS2_DIR=%MSYS2_ROOT%"
if not defined MSYS2_DIR if exist "C:\msys64\usr\bin\bash.exe" set "MSYS2_DIR=C:\msys64"
if not defined MSYS2_DIR goto :sm64_no_msys2

echo Using MSYS2 at %MSYS2_DIR%
set "MSYSTEM=MINGW64"
set "CHERE_INVOKING=1"
"%MSYS2_DIR%\usr\bin\bash.exe" -lc "pacman -S --needed --noconfirm make git unzip zip python3 mingw-w64-x86_64-gcc mingw-w64-x86_64-glew mingw-w64-x86_64-SDL2 && cd sm64coopdx && make -j$(nproc)"
if errorlevel 1 goto :sm64_failed

if not exist "sm64coopdx\build\us_pc\sm64coopdx.exe" goto :sm64_failed
set "RESULT_SM64=OK - sm64coopdx\build\us_pc\sm64coopdx.exe"
goto :after_sm64

:sm64_no_msys2
echo.
echo MSYS2 was not found. Install it from https://www.msys2.org (default folder
echo C:\msys64), or set the MSYS2_ROOT environment variable to where it lives,
echo then run this script again.
set "RESULT_SM64=FAILED - MSYS2 not found"
set "EXITCODE=1"
goto :after_sm64

:sm64_failed
echo.
echo The sm64coopdx build failed. Scroll up for the first error.
echo If pacman said a package was not found, open an "MSYS2 MSYS" terminal once
echo and run:  pacman -Syu   then run this script again.
set "RESULT_SM64=FAILED - see output above"
set "EXITCODE=1"
goto :after_sm64

:after_sm64
if /i "%TARGET%"=="all" goto :do_xbox
goto :summary

rem ----------------------------------------------------------------------------
rem  Minecraft Xbox 360 decompilation (CMake + Ninja + Xbox 360 XDK compiler)
rem ----------------------------------------------------------------------------
:do_xbox
echo.
echo === Minecraft Xbox 360 Decompilation ===
set "MC=%CD%\Minecraft-Xbox-360-Decompilation"
set "OUT=%MC%\out\build\%CONFIG%"

where cmake >nul 2>nul
if errorlevel 1 goto :xbox_no_cmake
where ninja >nul 2>nul
if errorlevel 1 goto :xbox_no_ninja
if not exist "%MC%\Compiler\bin\win32\cl.exe" goto :xbox_no_xdk

cmake -S "%MC%" -B "%OUT%" -G Ninja -DCMAKE_TOOLCHAIN_FILE="%MC%\Compiler\XMsvc.cmake" -DCMAKE_BUILD_TYPE=%CONFIG%
if errorlevel 1 goto :xbox_failed
cmake --build "%OUT%"
if errorlevel 1 goto :xbox_failed

set "RESULT_XBOX=OK - Minecraft-Xbox-360-Decompilation\out\build\%CONFIG%"
goto :summary

:xbox_no_cmake
echo CMake was not found on PATH. Install CMake 3.29 or newer from https://cmake.org
set "RESULT_XBOX=FAILED - CMake not found"
set "EXITCODE=1"
goto :summary

:xbox_no_ninja
echo Ninja was not found on PATH. Install it from https://ninja-build.org
echo or with:  winget install Ninja-build.Ninja
set "RESULT_XBOX=FAILED - Ninja not found"
set "EXITCODE=1"
goto :summary

:xbox_no_xdk
echo.
echo The Xbox 360 compiler was not found at:
echo   %MC%\Compiler\bin\win32\cl.exe
echo.
echo This project needs Microsoft's Xbox 360 XDK v2.0.21119, which is not
echo included in this repository. Copy the XDK's include, lib and bin folders
echo into Minecraft-Xbox-360-Decompilation\Compiler\ (see its README.md).
set "RESULT_XBOX=FAILED - XDK missing"
set "EXITCODE=1"
goto :summary

:xbox_failed
echo.
echo The Xbox 360 build failed. Scroll up for the first error.
set "RESULT_XBOX=FAILED - see output above"
set "EXITCODE=1"
goto :summary

rem ----------------------------------------------------------------------------
:summary
echo.
echo ==================== Summary ====================
echo   sm64coopdx:      %RESULT_SM64%
echo   Xbox 360 build:  %RESULT_XBOX%
echo =================================================

:finish
if "%INTERACTIVE%"=="1" pause
exit /b %EXITCODE%
