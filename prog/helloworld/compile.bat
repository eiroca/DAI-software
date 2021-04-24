for %%I in (.) do set target=%%~nxI
echo %target%
retroassembler -x %target%.8080.asm
del ..\%target%.sbin
move %target%.prg ..\%target%.sbin
