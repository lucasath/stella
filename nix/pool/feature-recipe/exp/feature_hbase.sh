if [ ! "$_hbase_INCLUDED_" = "1" ]; then
_hbase_INCLUDED_=1

# doc : https://hbase.apache.org/book.html

feature_hbase() {
	FEAT_NAME=hbase
	FEAT_LIST_SCHEMA="1_2_1:binary 1_1_5:binary"
	FEAT_DEFAULT_VERSION=1_1_5
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}


feature_hbase_1_2_1() {
	FEAT_VERSION=1_2_1
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES="oracle-jdk"

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=http://archive.apache.org/dist/hbase/1.2.1/hbase-1.2.1-bin.tar.gz
	FEAT_BINARY_URL_FILENAME=hbase-1.2.1-bin.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/hbase
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin:"$FEAT_INSTALL_ROOT"/sbin

}

feature_hbase_1_1_5() {
	FEAT_VERSION=1_1_5
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES="oracle-jdk#8u91"

	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=http://archive.apache.org/dist/hbase/1.1.5/hbase-1.1.5-bin.tar.gz
	FEAT_BINARY_URL_FILENAME=hbase-1.1.5-bin.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=


	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/hbase
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_hbase_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "STRIP"

}


fi
