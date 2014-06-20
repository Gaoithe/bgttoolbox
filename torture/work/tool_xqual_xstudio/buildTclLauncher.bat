@echo off
setlocal

REM ==================================================================================
REM XSTUDIO_J2SE_ROOT indicates which jdk to use for compilation
SET XSTUDIO_J2SE_ROOT=C:/Progra~1/Java/jdk1.6.0_16

REM XSTUDIO_LAUNCHER_NAME indicates the name of the launcher being compiled
SET XSTUDIO_LAUNCHER_NAME=tcl

REM XSTUDIO_SOURCE_FILES indicates which source files to compile
SET XSTUDIO_SOURCE_FILES=../src/com/xqual/xlauncher/CTimeoutListener.java ../src/com/xqual/xlauncher/%XSTUDIO_LAUNCHER_NAME%/CLauncherImpl.java

REM XSTUDIO_MAIN_CLASS indicates the classpath of the mainclass
SET XSTUDIO_MAIN_CLASS=com.xqual.xlauncher.%XSTUDIO_LAUNCHER_NAME%.CLauncherImpl

REM XSTUDIO_TEMP_FOLDER indicates the location where the class files will be created
SET XSTUDIO_TEMP_FOLDER=../classes

REM XSTUDIO_OUTPUT_FOLDER indicates the location where the jar file will be created
SET XSTUDIO_OUTPUT_FOLDER=../bin
REM ==================================================================================


if exist %XSTUDIO_J2SE_ROOT% goto checklib
   echo %XSTUDIO_J2SE_ROOT% does not exist ! please, edit this file and specify which JDK to use.
   goto end

:checklib

SET XSTUDIO_LAUNCHER_LIB=../lib/launcher_lib.jar

if exist %XSTUDIO_LAUNCHER_LIB% goto compile
   echo %XSTUDIO_LAUNCHER_LIB% does not exist ! please, edit this file and specify the library location.
   echo You may need to reinstall xstudio taking care of selecting libraries in the list of components to install.
   goto end

:compile

echo preparing environment...
mkdir "%XSTUDIO_TEMP_FOLDER%"
if exist "%XSTUDIO_OUTPUT_FOLDER%/%XSTUDIO_LAUNCHER_NAME%.jar" del "%XSTUDIO_OUTPUT_FOLDER%/%XSTUDIO_LAUNCHER_NAME%.jar"

echo compiling source code...
%XSTUDIO_J2SE_ROOT%/bin/javac -deprecation -d %XSTUDIO_TEMP_FOLDER% -classpath %XSTUDIO_LAUNCHER_LIB% %XSTUDIO_SOURCE_FILES%

echo generating Manifest...
echo Manifest-Version: 1.0> MANIFEST.MF
echo Ant-Version: Apache Ant 1.6.5>> MANIFEST.MF
echo Created-By: 1.6.0_02-b06 (Sun Microsystems Inc.)>> MANIFEST.MF
echo Main-Class: %XSTUDIO_MAIN_CLASS%>> MANIFEST.MF

echo packaging classes files in a JAR archive...
%XSTUDIO_J2SE_ROOT%/bin/jar cmf MANIFEST.MF %XSTUDIO_OUTPUT_FOLDER%/%XSTUDIO_LAUNCHER_NAME%.jar -C %XSTUDIO_TEMP_FOLDER% .

echo cleaning up...
rmdir /S /Q "%XSTUDIO_TEMP_FOLDER%"
del /F /Q MANIFEST.MF

echo terminated.

:end