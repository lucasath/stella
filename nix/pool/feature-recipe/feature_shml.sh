if [ ! "$_shml_INCLUDED_" = "1" ]; then
_shml_INCLUDED_=1



feature_shml() {
	FEAT_NAME=shml
	FEAT_LIST_SCHEMA="1_0_4:source"
	FEAT_DEFAULT_VERSION=1_0_4
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}


feature_shml_1_0_4() {
	FEAT_VERSION=1_0_4
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/odb/shml/archive/1.0.4.tar.gz
	FEAT_SOURCE_URL_FILENAME=shml-1.0.4.tar.gz
	FEAT_SOURCE_URL_PROTOCOL=HTTP_ZIP

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/shml.sh
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"

}



feature_shml_install_source() {
	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "STRIP DEST_ERASE FORCE_NAME $FEAT_SOURCE_URL_FILENAME"
	chmod +x $FEAT_INSTALL_ROOT/shml.sh
}


fi
