if [ ! "$_DOCKERMACHINE_INCLUDED_" == "1" ]; then 
_DOCKERMACHINE_INCLUDED_=1


function feature_docker-machine() {
	FEAT_NAME=docker-machine
	FEAT_LIST_SCHEMA="0_2_0@x64/binary 0_2_0@x86/binary"
	FEAT_DEFAULT_VERSION=0_2_0
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR=binary
}

function feature_docker-machine_0_2_0() {
	FEAT_VERSION=0_2_0
	FEAT_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=
	
	if [ "$STELLA_CURRENT_PLATFORM" == "darwin" ]; then
		FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_darwin-386
		FEAT_BINARY_URL_FILENAME_x86=docker-machine_darwin-386-0_2_0
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP

		FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_darwin-amd64
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_darwin-amd64-0_2_0
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP
	fi
	if [ "$STELLA_CURRENT_PLATFORM" == "linux" ]; then
		FEAT_BINARY_URL_x86=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_linux-386
		FEAT_BINARY_URL_FILENAME_x86=docker-machine_linux-386-0_2_0
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP

		FEAT_BINARY_URL_x64=https://github.com/docker/machine/releases/download/v0.2.0/docker-machine_linux-amd64
		FEAT_BINARY_URL_FILENAME_x64=docker-machine_linux-amd64-0_2_0
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/docker-machine
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
	
}



function feature_docker-machine_install_binary() {
	
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	mv $FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME $FEAT_INSTALL_ROOT/docker-machine
	chmod +x $FEAT_INSTALL_ROOT/docker-machine
}


fi