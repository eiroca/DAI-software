if "%DIST%"=="" set DIST=..\
for %%I in (.) do set target=%%~nxI
echo %target%
del %target%.sbin
retroassembler -x %target%.8080.asm
move %target%.prg %target%.sbin
dtcli %target%.sbin -c DAI_(basic)
dtcli %target%.dai -c wav
del %target%.sbin
del %DIST%%target%.dai
del %DIST%%target%.wav
move %target%.dai %DIST%%target%.dai
move %target%.wav %DIST%%target%.wav
