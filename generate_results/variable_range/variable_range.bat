@echo off

set domain_sizes="10" "25" "50" "100" "250" "500" "1000" "2500" "5000" "10000"

set ratios="0.001" "0.01" "0.1" "0.2" "0.3" "0.4" "0.5" "0.6" "0.7" "0.8" "0.9" "1"

set /A count=0
set max_count=36000

for %%a in (%domain_sizes%) do (

	for %%d in (%ratios%) do (
		echo %%d
		start "test" /I java -jar ../../bin/java/Main.jar %%a %%d
		
		call :check
		
		taskkill /f /fi "Windowtitle eq test" /im "java.exe"
		
		timeout 10
		set count=0
	)

)
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