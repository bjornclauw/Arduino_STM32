@echo off


rem: Note %~dp0 get path of this batch file
rem: Need to change drive if My Documents is on a drive other than C:
set driverLetter=%~dp0
set driverLetter=%driverLetter:~0,2%
%driverLetter%
cd %~dp0
rem: the two line below are needed to fix path issues with incorrect slashes before the bin file name
set str=%4
set str=%str:/=\%

rem: get ip adress to upload to
set OTAip=%1


cd  "%ProgramFiles(x86)%\com0com\"
start com2tcp --terminal RAW --baud 115200 --data 8 --parity e --stop 1   \\.\COM51 %OTAip% 23
rem: ping %OTAip%

rem: send command via telnet scripter
set host=%OTAip% 23
(
echo %host%
echo SEND "otastm"
echo WAIT "STM32 OTA MODE"
)>"%temp%\tst.script"
start /WAIT tst10.exe /r:"%temp%\tst.script" 
del "%temp%\tst.script" 
rem: END send command via telnet scripter 

rem: ---- UPLOADER: 64 k version
cd "%ProgramFiles(x86)%\STMicroelectronics\Software\Flash Loader Demo\"
start /WAIT STMFlashLoader  -c --pn 50 --br 115200  -i STM32F1_Med-density_64K -e --all -d --fn %str% --a 0x8000000 -r --a 0x8000000 
taskkill /IM com2tcp.exe

rem: send command via telnet scripter
cd  "%ProgramFiles(x86)%\com0com\"
set host=%OTAip% 23
(
echo %host%
echo SEND "otarst"
echo WAIT "STM32 RESET"
)>"%temp%\tst.script"
start /WAIT tst10.exe /r:"%temp%\tst.script" 
del "%temp%\tst.script" 
rem: END send command via telnet scripter 
echo "STM32 programmed successfully"
