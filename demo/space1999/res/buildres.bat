del /Q converted\*.*
del /Q output\*.*
del /Q final\*.*
del *.zx1
DTcli.exe -g png_(fast) -o converted\ orig\*.png
DTcli.exe -g bin -o final\ edited\image0*.png
DTcli.exe -f bin -o output\frame.bin final\image00.bin final\image01.bin final\image02.bin final\image03.bin final\image04.bin
DTcli.exe -c bin -o output\frame.005.bin edited\image10.hrfb
DTcli.exe -g bin -z -o output\frame.006.bin edited\image20.png
zx1 -b output\frame.000.bin frame.000.bin.zx1
zx1 -b output\frame.001.bin frame.001.bin.zx1
zx1 -b output\frame.002.bin frame.002.bin.zx1
zx1 -b output\frame.003.bin frame.003.bin.zx1
zx1 -b output\frame.004.bin frame.004.bin.zx1
zx1 -b output\frame.005.bin frame.005.bin.zx1
zx1 -b output\frame.006.bin frame.006.bin.zx1
del /Q converted\*.*
del /Q final\*.*
del /Q output\*.*
