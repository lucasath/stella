if [ ! "$_wildfly_INCLUDED_" = "1" ]; then 
_wildfly_INCLUDED_=1

# wildfly is the new name for JBOSS Application Server
#  7.1.1.Final is the last version as JBOSS AS

feature_wildfly() {
	FEAT_NAME=wildfly
	FEAT_LIST_SCHEMA="7_1_1_FINAL:binary 8_2_1_FINAL 9_0_2_FINAL 10_0_0_FINAL:binary"
	FEAT_DEFAULT_VERSION=10_0_0_FINAL
	FEAT_DEFAULT_ARCH=
	FEAT_DEFAULT_FLAVOUR="binary"
}


feature_wildfly_10_0_0_FINAL() {
	FEAT_VERSION=10_0_0_FINAL
	# TODO NEED JAVA 8
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=
	
	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=http://download.jboss.org/wildfly/10.0.0.Final/wildfly-10.0.0.Final.tar.gz
	FEAT_BINARY_URL_FILENAME=wildfly-10.0.0.Final.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/standalone.sh
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_wildfly_9_0_2_FINAL() {
	FEAT_VERSION=9_0_2_FINAL
	# TODO NEED JAVA 7
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=
	
	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=http://download.jboss.org/wildfly/9.0.2.Final/wildfly-9.0.2.Final.tar.gz
	FEAT_BINARY_URL_FILENAME=wildfly-9.0.2.Final.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/standalone.sh
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_wildfly_8_2_1_FINAL() {
	FEAT_VERSION=8_2_1_FINAL
	# TODO NEED JAVA 7
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=
	
	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=http://download.jboss.org/wildfly/8.2.1.Final/wildfly-8.2.1.Final.tar.gz
	FEAT_BINARY_URL_FILENAME=wildfly-8.2.1.Final.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/standalone.sh
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}



feature_wildfly_7_1_1_FINAL() {
	FEAT_VERSION=7_1_1_FINAL
	# TODO NEED JAVA 6
	FEAT_SOURCE_DEPENDENCIES=
	FEAT_BINARY_DEPENDENCIES=
	
	FEAT_SOURCE_URL=
	FEAT_SOURCE_URL_FILENAME=
	FEAT_SOURCE_URL_PROTOCOL=

	FEAT_BINARY_URL=http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
	FEAT_BINARY_URL_FILENAME=jboss-as-7.1.1.Final.tar.gz
	FEAT_BINARY_URL_PROTOCOL=HTTP_ZIP

	FEAT_SOURCE_CALLBACK=
	FEAT_BINARY_CALLBACK=
	FEAT_ENV_CALLBACK=

	FEAT_INSTALL_TEST="$FEAT_INSTALL_ROOT"/bin/standalone.sh
	FEAT_SEARCH_PATH="$FEAT_INSTALL_ROOT"/bin

}


feature_wildfly_install_binary() {
	__get_resource "$FEAT_NAME" "$FEAT_BINARY_URL" "$FEAT_BINARY_URL_PROTOCOL" "$FEAT_INSTALL_ROOT" "STRIP"


}


fi
