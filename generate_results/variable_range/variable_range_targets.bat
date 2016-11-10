@echo off

set domain_sizes="500"

set ratios="0.2"

set /A count=0
set max_count=36000


echo %%d
start "test" /I java -jar ../../bin/java/Main.jar "500" "0.2"

call :check

taskkill /f /fi "Windowtitle eq test" /im "java.exe"

timeout 10
set count=0


echo %%d
start "test" /I java -jar ../../bin/java/Main.jar "5000" "0.9"

call :check

taskkill /f /fi "Windowtitle eq test" /im "java.exe"

timeout 10
set count=0


goto :eof

:check

:loop
tasklist /fi "Windowtitle eq test" |find ":"

if %count% LSS %max_count% (
	if "%ERRORLEVEL%"=="1" (
		set TRUE=1
	) else (
		set TRUE=0
	)
) else (
	@echo Terminating run >> ../../src/test/result_generation/PartialRangeLargeDomain/results.txt
	set TRUE=0
) 

if %TRUE% EQU 1 (
	timeout 1
	set /A count=count+1
	echo time %count%
	goto :loop
)

:endloop

goto :eof