if [ ! "$_bats_INCLUDED_" == "1" ]; then
_bats_INCLUDED_=1



function feature_bats() {
	FEAT_NAME=bats
	FEAT_LIST_SCHEMA="SNAPSHOT:source"
	FEAT_DEFAULT_VERSION=SNAPSHOT
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="source"
}



function bats_internal_test() {
	cp -R "$SRC_DIR/test" "$INSTALL_DIR/test"
}


function feature_bats_SNAPSHOT() {
	FEAT_VERSION=SNAPSHOT

	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=

	FEAT_SOURCE_URL=https://github.com/sstephenson/bats
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=GIT

	FEAT_BINARY_URL=
	FEAT_BINARY_URL_FILENAME=
	FEAT_BINARY_URL_PROTOCOL=

	FEAT_SOURCE_CALLBACK=bats_internal_test
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/bats
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


function feature_bats_install_source() {
	INSTALL_DIR="$FEAT_INSTALL_ROOT"
	SRC_DIR="$STELLA_APP_FEATURE_ROOT/$FEAT_NAME-$FEAT_VERSION-src"

	#__set_toolset "STANDARD"


	__get_resource "$FEAT_NAME" "$FEAT_SOURCE_URL" "$FEAT_SOURCE_URL_PROTOCOL" "$SRC_DIR" "DEST_ERASE"

	cd "$SRC_DIR"
	./install.sh "$INSTALL_DIR"

	__feature_callback

	rm -Rf "$SRC_DIR"

}




fi
