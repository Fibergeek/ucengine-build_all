@ECHO OFF

REM *** Compiler configuration ***
REM (modify this if needed)
SET __compiler=Visual Studio 16 2019
SET __compiler=Visual Studio 17 2022
SET __clean=

REM *** Script configuration ***
GOTO :CompileAll

:Compile
REM *** Create a temporary, empty directory ***
CD %~DP0
IF "%__clean%" NEQ "" MKDIR empty >NUL

SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%p IN (%__platforms%) DO (
  FOR %%t IN (%__buildtypes%) DO (
    CD %~DP0
    SET __outputdir=%%p-%%t-%__output%
    IF NOT EXIST !__outputdir! MKDIR !__outputdir!
    CD !__outputdir!
    ECHO =================================================
    CD
    ECHO =================================================
    IF "%__clean%" NEQ "" ROBOCOPY ..\empty . /MIR >NUL
    ECHO RUNNING: cmake -G "NMake Makefiles" ..\.. -G "%__compiler%" -A %%p -DCMAKE_BUILD_TYPE=%%t %__extra%
    cmake ..\.. -G "%__compiler%" -A %%p -DCMAKE_BUILD_TYPE=%%t %__extra%
    ECHO RUNNING: msbuild unicorn.sln -p:Platform=%%p -p:Configuration=%%t
    msbuild unicorn.sln -p:Platform=%%p -p:Configuration=%%t
    ECHO.
    ECHO.
  )
)

REM *** Clean-up the temporary, empty directory ***
CD %~DP0
IF "%__clean%" NEQ "" RMDIR empty >NUL
GOTO :EOF

:CompileAll
REM To compile only x86 and ARM you can add to __extra:
REM  -DUNICORN_ARCH=x86;arm 

REM *** Compile dynamic library versions ***
REM NOTE: these are case-sensitive!
SET "__platforms=win32 x64"
SET "__buildtypes=Debug Release"
SET "__output=DLL"
SET "__extra=-DUNICORN_INSTALL=OFF -DUNICORN_BUILD_TESTS=OFF
CALL :Compile

REM *** Compile static library versions ***
SET "__output=Lib"
SET "__extra=-DUNICORN_INSTALL=OFF -DUNICORN_BUILD_TESTS=OFF -DBUILD_SHARED_LIBS=OFF"
CALL :Compile

REM *** Clean-up ***
SET __output=
SET __platforms=
SET __buildtypes=
SET __compiler=
SET __outputdir=
