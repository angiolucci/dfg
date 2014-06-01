:: -----------------------------------------------------
:: script para limpeza e desfragmenta��o de disco
:: Vin�cius A. Reis
:: 01/2011
:: -----------------------------------------------------

@echo off
cls

if "%OS%"=="Windows_NT" (
	call:config
	call:shwhdr
	call:chkdisk
	if not "%faildisk%"=="1" (
		call:dvrclean
		call:dfrg
		call:dfrg -boot
		call:purge
		call:halt
	) else (
		echo Your system cannot be cleanned while there are
		echo errors on filesystem at %drive%.
		echo Please, use Windows CheckDisk, this scirpt
		echo or other software to verify and repair your filesystem.
		echo.
		echo If a scan is scheduled to run on next boot time, 
		echo just restart your computer to perform a disk analysis.
		goto:eof
	)
) else (
	call:wrgsys
)
goto:eof

 ::----------------------------------------------------
 ::-- Functions section starts below here
 ::----------------------------------------------------
 
:wrgsys
	echo This scripts works only on Windows NT based systems
	echo such as Windows XP/2003/Vista/Seven/2008.
	echo.
	echo To avoid to crash your system, this script will be 
	echo closed.
goto:eof

:shwhdr
	echo ======================================
	echo ==                                  ==
	echo == System Cleaner scirpt %version%     ==
	echo ==                                  ==
	echo ======================================
	ver
	echo.
	echo.
goto:eof

:firstrun
	echo Welcome to the System Cleaner script !
	echo.
	echo This is the very first time that you're running
	echo this script on this machine, so we need to do 
	echo some tweaks before we begin to clean up the SYS!
	echo.
	echo In the next screen, we'll choose all the features
	echo that you want to clean with this script.
	echo We recommend to check them all!!
	echo.
	echo If you have Piriform Ccleaner installed, it will be
	echo openned too, so you can select in the checkboxes
	echo all the features that you want to perform.
	echo.
	echo Press any KEY to configure ...
	pause > nul
	start /wait cleanmgr /d %1 /sageset:%2
	if exist "%programfiles%\ccleaner\ccleaner.exe" (
		start /wait ccleaner
	)
	echo 0 > %systemroot%\dfg.dat
	cls
	echo This is it...
	echo So, let's clean !
	echo.
	echo Press any KEY to continue ...
	cls
goto:eof

:config
	set drive=%systemdrive%
	set /a sage=11
	set /a halt_time=55
	set /a halt_time=%halt_time% + 5
	set version=0.1.0a
	set name=System TuneUP
	title %name%
	
	if not exist "%systemroot%\dfg.dat" ( 
		call:firstrun %drive%  %sage%
	)
goto:eof

:purge
	set drive=
	set sage=
	REM set halt_time=
	set name=
	if exist %tmp%\dfg.tmp del /q %tmp%\dfg.tmp
	title %comspec%
goto:eof

:dvrclean
	echo * Running disk cleaner on %drive%
	start /wait cleanmgr /d %drive%  /sagerun:%sage%
	if "exist %programfiles%\ccleaner\ccleaner.exe" (
		start /wait ccleaner /auto
	)
goto:eof

:dfrg
	if "%1"=="" (
		echo * Running disk defrag on %drive%
		defrag  %drive% > nul
	) else (
		if "%1"=="-boot" (
			echo * Running  boot optimization on %drive%
			defrag -b %drive% > nul
		)
	)
goto:eof

:chkdisk
	echo * Checking for errors on %drive%
	chkdsk %drive% > nul
	if not errorlevel 0 (
		set faildisk=1
		echo.
		echo An error on filesystem at %drive% have been detected.
		echo The disk will be verified using Windows CheckDisk
		echo at next time that you restart your computer.
		echo.
		echo S > %tmp%\dfg.tmp
		chkdsk /f /r %drive% < %tmp%\dfg.tmp
		del /q %tmp%\dfg.tmp
	)
goto:eof

:reboot
	echo * Rebooting NOW ...
	shutdown -r -t 2
goto:eof

:halt
	echo * System going to halt in %halt_time% secs!
	shutdown -s -t %halt_time%
goto:eof
