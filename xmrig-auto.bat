@ECHO OFF
CLS
ECHO.

REM Warn if script wasn't run as admin
NET FILE 1>NUL 2>NUL & IF ERRORLEVEL 1 (
	ECHO You must right-click and select
	ECHO "Run as Administrator" to use the auto MSR settings.
	ECHO.
	PAUSE
)


REM Get L3 cache size in MB
FOR /F "usebackq tokens=* delims=" %%g IN (`wmic cpu get L3CacheSize ^| findstr /v L3 ^| findstr ^[0-9]`) DO (SET /a L3CACHE=%%g / 1024)

REM Add 1 to L3 cache and divide by 2 to get the number of 2MB chunks available rounded up to the nearest integer
SET /A L3CHUNKS=(%L3CACHE% + 1) / 2

REM Physical core count
FOR /F "usebackq tokens=* delims=" %%g IN (`wmic cpu get NumberOfCores ^| findstr /v NumberOfCores ^| findstr ^[0-9]`) DO (SET /A PHYSCORES=%%g)

REM Logical core / thread count
FOR /F "usebackq tokens=* delims=" %%g IN (`wmic cpu get NumberOfLogicalProcessors ^| findstr /v NumberOfLogicalProcessors ^| findstr ^[0-9]`) DO (SET /A LOGCORES=%%g)


REM If the number of 2MB chunks is more than the number of logical cores, use max cores instead
IF %LOGCORES% LSS %L3CHUNKS% (SET THREADS=%LOGCORES%) ELSE (SET THREADS=%L3CHUNKS%)

REM Print variables for debugging/reference
ECHO PHYSCORES=%PHYSCORES%
ECHO LOGCORES=%LOGCORES%
ECHO L3CACHE=%L3CACHE%
ECHO L3CHUNKS=%L3CHUNKS%
ECHO THREADS=%THREADS%

REM Check that xmrig.exe and config.json are both in the same folder as the batch file.
REM If both are present, run xmrig.exe with the specified number of threads
IF EXIST %~dp0\xmrig.exe (
	IF EXIST %~dp0\config.json (
		%~dp0\xmrig.exe -c %~dp0\config.json -t %THREADS%
	) ELSE (
		ECHO config.json not found in %~dp0
	)
) ELSE (
	ECHO xmrig.exe not found in %~dp0
)
PAUSE
