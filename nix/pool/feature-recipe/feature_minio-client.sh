if [ ! "$_MINIOCLIENT_INCLUDED_" = "1" ]; then
_MINIOCLIENT_INCLUDED_=1


feature_minio-client() {

	FEAT_NAME=minio-client
	[ "$STELLA_CURRENT_PLATFORM" = "darwin" ] && FEAT_LIST_SCHEMA="latest@x64:binary"
	[ "$STELLA_CURRENT_PLATFORM" = "linux" ] && FEAT_LIST_SCHEMA="latest@x64:binary latest@x86:binary"
	FEAT_DEFAULT_ARCH=x64
	FEAT_DEFAULT_FLAVOUR="binary"
}

feature_minio-client_latest() {
	FEAT_VERSION=latest

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	# NOTE we use $(date +%s) as a timestamp to invalidate cached version, because this is the latest
	if [ "$STELLA_CURRENT_PLATFORM" = "darwin" ]; then
		FEAT_BINARY_URL_x64=https://dl.minio.io/client/mc/release/darwin-amd64/mc
		FEAT_BINARY_URL_FILENAME_x64="mc_${FEAT_VERSION}_darwin_$(date +%s)"
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP
	fi
	if [ "$STELLA_CURRENT_PLATFORM" = "linux" ]; then
		FEAT_BINARY_URL_x64=https://dl.minio.io/client/mc/release/linux-amd64/mc
		FEAT_BINARY_URL_FILENAME_x64="mc_${FEAT_VERSION}_linux_amd64_$(date +%s)"
		FEAT_BINARY_URL_PROTOCOL_x64=HTTP
		FEAT_BINARY_URL_x86=https://dl.minio.io/client/mc/release/linux-386/mc
		FEAT_BINARY_URL_FILENAME_x86="mc_${FEAT_VERSION}_linux_x86_$(date +%s)"
		FEAT_BINARY_URL_PROTOCOL_x86=HTTP
	fi

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/mc
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"
}

# -----------------------------------------
feature_minio-client_install_binary() {

	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "FORCE_NAME $FEAT_BINARY_URL_FILENAME"
	mv -f "$FEAT_INSTALL_ROOT/$FEAT_BINARY_URL_FILENAME" "$FEAT_INSTALL_ROOT/mc"
	chmod +x "$FEAT_INSTALL_ROOT/mc"

}




fi
