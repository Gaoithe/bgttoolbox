@echo off

rem Errors & carefulness needed:
rem Beware of using labels longer than 8  :EXITWARNFOO and :EXITWARNOTHER are same
rem If no jpg files nothing is done even if dir has subdirs or mpg files
rem If don't cd to directory env vars take up more space and after 3 we're out of environment!!!!!!
rem ""s in html file are bleh but I don't have msdos manual (doesn't come with windoze)
rem width 480 seems to be about 2/3rds? ish of A4 portrait, try 640

if "%1"=="/?" GOTO USAGE
if "%1"=="" GOTO USAGE

cd %1

set outfile=index.html
set l-outfile=l-index.html
set t-outfile=t-index.html
set p-outfile=p-index.html

echo genhtmlF   Directory:  %1    
echo            Generating: %outfile% %l-outfile% %t-outfile%

rem check if outfile exists, exit with warning if so.
if exist %outfile% goto EXITINDEXFILEs
:RTNINDEX
rem check if jpg or mpg files exist, exit with warning if not so.
if not exist *.jpg goto EXITNOFILE

echo "<html><head><title>%1</title></head><body>" >%outfile%
echo "<a href=index.html>Index</a> <a href=t-index.html>Thumb</a> <a href=l-index.html>Link</a> <a href=p-index.html>Print</a> %1" >>%outfile%

echo "<html><head><title>%1 thumbs</title></head><body>" >%t-outfile%
echo "<a href=index.html>Index</a> <a href=t-index.html>Thumb</a> <a href=l-index.html>Link</a> <a href=p-index.html>Print</a> %1" >>%t-outfile%

echo "<html><head><title>%1 links</title></head><body>" >%l-outfile%
echo "<a href=index.html>Index</a> <a href=t-index.html>Thumb</a> <a href=l-index.html>Link</a> <a href=p-index.html>Print</a> %1" >>%l-outfile%

echo "<html><head><title>%1 links</title></head><body>" >%p-outfile%
echo "<a href=index.html>Index</a> <a href=t-index.html>Thumb</a> <a href=l-index.html>Link</a> <a href=p-index.html>Print</a> %1" >>%p-outfile%

for %%i in (*.jpg) do echo "<br><img src=%%i>%%i" >>%outfile%
for %%i in (*.mpg) do echo "<br><a href=%%i>%%i</a>" >>%outfile%
for %%i in (*.jpg) do echo "<br><a href=%%i><img src=%%i width=80>%%i</a>" >>%t-outfile%
for %%i in (*.mpg) do echo "<br><a href=%%i>%%i</a>" >>%t-outfile%
for %%i in (*.jpg) do echo "<br><a href=%%i>%%i</a>" >>%l-outfile%
for %%i in (*.mpg) do echo "<br><a href=%%i>%%i</a>" >>%l-outfile%

for %%i in (*.jpg) do echo "<br><img src=%%i width=640>" >>%p-outfile%/
echo test

rem explorer DSC00073.JPG
rem echo Enter caption for this picture
rem pause
rem get foo

echo "</body></html>" >>%l-outfile%
echo "</body></html>" >>%outfile%
echo "</body></html>" >>%t-outfile%
echo "</body></html>" >>%p-outfile%

echo  %outfile% Should now exist
choice You wanna see? /c:yn
if errorlevel 2 goto END
if errorlevel 1 explorer %outfile%
goto END

:USAGE
echo.
echo Make html files (thumb/full/link) of all files (mpg and jpg) in specified directory
echo   e.g. genhtmlF D:\Photos\HedgehogInBackGarden
echo  (Drag folder to this bat file in Windoze GUI)
echo.
goto END

:EXITNOFILE
echo Exiting without doing anything.
echo No jpg or mpg files found in that directory.
goto END

:EXITINDEXFILE
echo  %outfile% file in that directory would be overwritten.
echo Delete it manually if you want to genhtmlF on this folder.
choice You wanna see it? /c:yn
if errorlevel 2 goto SKIPINDEX
if errorlevel 1 explorer %outfile%
:SKIPINDEX
choice You wanna delete it and regenerate? /c:yn
if errorlevel 2 goto END
del %outfile%
goto RTNINDEX

:END
echo all done.

rem set foo=`dir`
rem echo %foo%
rem set

rem if exist *.jpg echo jpg %1 %%i
rem if exist *.JPG echo JPG
rem if exist D:\PhotosFromCamera\Autumn2001\Trabolgan\Butterflies&Walk\test.bat echo bat

