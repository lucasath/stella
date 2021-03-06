@setlocal enableExtensions enableDelayedExpansion
@echo off

call %~dp0\stella-link.bat include

call :test_translate_schema

rem call :test_feature_install

goto :eof




:test_translate_schema

set RESULT=ERROR
set "TEST=wget#1_2@x86:source/ubuntu"
call %STELLA_COMMON%\common-feature.bat :translate_schema "%TEST%" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
if "%TR_FEATURE_NAME%"=="wget" if "%TR_FEATURE_OS_RESTRICTION%"=="ubuntu" if "%TR_FEATURE_VER%"=="1_2" if "%TR_FEATURE_ARCH%"=="x86" if "%TR_FEATURE_FLAVOUR%"=="source" if "%TR_FEATURE_OS_EXCLUSION%"=="" set RESULT=OK
echo %RESULT% : %TEST% =^> %TR_FEATURE_NAME%/%TR_FEATURE_OS_RESTRICTION%\%TR_FEATURE_OS_EXCLUSION%#%TR_FEATURE_VER%@%TR_FEATURE_ARCH%:%TR_FEATURE_FLAVOUR%


set RESULT=ERROR
set "TEST=wget/ubuntu#1_2@x86:source"
call %STELLA_COMMON%\common-feature.bat :translate_schema "%TEST%" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
if "%TR_FEATURE_NAME%"=="wget" if "%TR_FEATURE_OS_RESTRICTION%"=="ubuntu" if "%TR_FEATURE_VER%"=="1_2" if "%TR_FEATURE_ARCH%"=="x86" if "%TR_FEATURE_FLAVOUR%"=="source" if "%TR_FEATURE_OS_EXCLUSION%"=="" set RESULT=OK
echo %RESULT% : %TEST% =^> %TR_FEATURE_NAME%/%TR_FEATURE_OS_RESTRICTION%\%TR_FEATURE_OS_EXCLUSION%#%TR_FEATURE_VER%@%TR_FEATURE_ARCH%:%TR_FEATURE_FLAVOUR%

set RESULT=ERROR
set "TEST=wget:source@x86"
call %STELLA_COMMON%\common-feature.bat :translate_schema "%TEST%" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
if "%TR_FEATURE_NAME%"=="wget" if "%TR_FEATURE_OS_RESTRICTION%"=="" if "%TR_FEATURE_VER%"=="" if "%TR_FEATURE_ARCH%"=="x86" if "%TR_FEATURE_FLAVOUR%"=="source" if "%TR_FEATURE_OS_EXCLUSION%"=="" set RESULT=OK
echo %RESULT% : %TEST% =^> %TR_FEATURE_NAME%/%TR_FEATURE_OS_RESTRICTION%\%TR_FEATURE_OS_EXCLUSION%#%TR_FEATURE_VER%@%TR_FEATURE_ARCH%:%TR_FEATURE_FLAVOUR%

set RESULT=ERROR
set "TEST=wget"
call %STELLA_COMMON%\common-feature.bat :translate_schema "%TEST%" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
if "%TR_FEATURE_NAME%"=="wget" if "%TR_FEATURE_OS_RESTRICTION%"=="" if "%TR_FEATURE_VER%"=="" if "%TR_FEATURE_ARCH%"=="" if "%TR_FEATURE_FLAVOUR%"=="" if "%TR_FEATURE_OS_EXCLUSION%"=="" set RESULT=OK
echo %RESULT% : %TEST% =^> %TR_FEATURE_NAME%/%TR_FEATURE_OS_RESTRICTION%\%TR_FEATURE_OS_EXCLUSION%#%TR_FEATURE_VER%@%TR_FEATURE_ARCH%:%TR_FEATURE_FLAVOUR%


set RESULT=ERROR
set "TEST=wget#1_2\windows"
call %STELLA_COMMON%\common-feature.bat :translate_schema "%TEST%" "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION" "TR_FEATURE_OS_EXCLUSION"
if "%TR_FEATURE_NAME%"=="wget" if "%TR_FEATURE_OS_RESTRICTION%"=="" if "%TR_FEATURE_VER%"=="1_2" if "%TR_FEATURE_ARCH%"=="" if "%TR_FEATURE_FLAVOUR%"=="" if "%TR_FEATURE_OS_EXCLUSION%"=="windows" set RESULT=OK
echo %RESULT% : %TEST% =^> %TR_FEATURE_NAME%/%TR_FEATURE_OS_RESTRICTION%\%TR_FEATURE_OS_EXCLUSION%#%TR_FEATURE_VER%@%TR_FEATURE_ARCH%:%TR_FEATURE_FLAVOUR%



goto :eof


:test_feature_install
	call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_FEATURE_LIST" ""

	set RESULT=ERROR
	set "TEST=wget#1_11_4/windows"
	call %STELLA_COMMON%\common-feature.bat :feature_install "%TEST%"
	call %STELLA_COMMON%\common-feature.bat :feature_catalog_info "%TEST%"
	if "%FEAT_INSTALL_ROOT%"=="%STELLA_APP_FEATURE_ROOT%\wget\1_11_4" if "%FEAT_VERSION%"=="1_11_4" set RESULT=OK
	echo %RESULT% : %TEST% =^> ROOT=!FEAT_INSTALL_ROOT! VER=%FEAT_VERSION%
	call %STELLA_COMMON%\common.bat :get_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_FEATURE_LIST"
	echo APP_FEATURE_LIST=%APP_FEATURE_LIST%
	call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_FEATURE_LIST" ""

	set RESULT=ERROR
	set "TEST=patch"
	call %STELLA_COMMON%\common-feature.bat :feature_install "%TEST%"
	call %STELLA_COMMON%\common-feature.bat :feature_catalog_info "%TEST%"
	if "%FEAT_INSTALL_ROOT%"=="%STELLA_APP_FEATURE_ROOT%\patch\%FEAT_VERSION%" set RESULT=OK
	echo %RESULT% : %TEST% =^> ROOT=!FEAT_INSTALL_ROOT! VER=%FEAT_VERSION%
	call %STELLA_COMMON%\common.bat :get_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_FEATURE_LIST"
	echo APP_FEATURE_LIST=%APP_FEATURE_LIST%
	call %STELLA_COMMON%\common.bat :add_key "%_STELLA_APP_PROPERTIES_FILE%" "STELLA" "APP_FEATURE_LIST" ""

goto :eof



@echo on