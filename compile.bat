@echo off
set DIST=%cd%\dist\
echo Destination = %DIST%
cd demo
cd pic
call compile.bat
cd ..
cd space1999
call compile.bat
cd ..
cd ..
cd prog
cd helloworld
call compile.bat
cd ..
cd ..
cd utility
cd testmem
call compile.bat
cd ..
cd cpudiag
call compile.bat
cd ..
cd DAIexerciser
call compile.bat
cd ..
cd ..

