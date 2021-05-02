for %%I in (.) do set target=%%~nxI
echo %target%
retroassembler -x %target%.8080.asm
move %target%.prg %target%.sbin
dtcli %target%.sbin -c DAI_(basic)
dtcli %target%.dai -c wav
rem del %target%.sbin
del ..\%target%.dai
del ..\%target%.wav
move %target%.dai ..\%target%.dai
move %target%.wav ..\%target%.wav
