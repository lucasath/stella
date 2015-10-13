@echo off
call %*
goto :eof

:feature_zlib
	set "FEAT_NAME=zlib"
	set "FEAT_LIST_SCHEMA=1_2_8:source"
	set "FEAT_DEFAULT_VERSION=1_2_8"
	set "FEAT_DEFAULT_ARCH="
	set "FEAT_DEFAULT_FLAVOUR=source"
goto :eof


:feature_zlib_1_2_8
	set "FEAT_VERSION=1_2_8"
	set FEAT_SOURCE_DEPENDENCIES=
	set FEAT_BINARY_DEPENDENCIES=

	set "FEAT_SOURCE_URL=http://zlib.net/zlib128.zip"
	set "FEAT_SOURCE_URL_FILENAME=zlib128.zip"
	set "FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP"
	
	set FEAT_BINARY_URL=
	set FEAT_BINARY_URL_FILENAME=
	set FEAT_BINARY_URL_PROTOCOL=
	
	set FEAT_SOURCE_CALLBACK=
	set FEAT_BINARY_CALLBACK=
	set FEAT_ENV_CALLBACK=

	set "FEAT_INSTALL_TEST=!FEAT_INSTALL_ROOT!\bin\zlib1.dll"
	set "FEAT_SEARCH_PATH=!FEAT_INSTALL_ROOT!"	

goto :eof


:feature_zlib_install_source
	set "INSTALL_DIR=!FEAT_INSTALL_ROOT!"
	set "SRC_DIR=!STELLA_APP_FEATURE_ROOT!\!FEAT_NAME!-!FEAT_VERSION!-src"
	

	call %STELLA_COMMON%\common-build.bat :set_toolset "MS"
	REM call %STELLA_COMMON%\common-build.bat :set_toolset "CUSTOM" "CONFIG_TOOL cmake BUILD_TOOL ninja COMPIL_FRONTEND cl"
	REM call %STELLA_COMMON%\common-build.bat :set_toolset "CUSTOM" "CONFIG_TOOL cmake COMPIL_FRONTEND gcc"


	call %STELLA_COMMON%\common.bat :get_resource "!FEAT_NAME!" "!FEAT_SOURCE_URL!" "!FEAT_SOURCE_URL_PROTOCOL!" "!SRC_DIR!" "DEST_ERASE STRIP"	



	set "AUTO_INSTALL_CONF_FLAG_POSTFIX="
	if "!FEAT_ARCH!"=="x86" set "AUTO_INSTALL_CONF_FLAG_POSTFIX=-DAMD64=OFF"

	set "AUTO_INSTALL_BUILD_FLAG_POSTFIX="
	

	call %STELLA_COMMON%\common-feature.bat :feature_callback

	:: out of tree build do not work
	call %STELLA_COMMON%\common-build.bat :auto_build "!FEAT_NAME!" "!SRC_DIR!" "!INSTALL_DIR!" "BUILD_KEEP SOURCE_KEEP"

goto :eof



