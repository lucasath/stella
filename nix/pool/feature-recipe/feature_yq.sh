if [ ! "$_yq_INCLUDED_" = "1" ]; then
_yq_INCLUDED_=1

feature_yq() {
	FEAT_NAME="yq"
	FEAT_LIST_SCHEMA="3_1_2@x64:binary 3_1_2@x86:binary"
	FEAT_DEFAULT_ARCH="x64"
	FEAT_DEFAULT_FLAVOUR="binary"

	FEAT_DESC="yq is a portable command-line YAML processor "
	FEAT_LINK="https://mikefarah.gitbook.io/yq/ https://github.com/mikefarah/yq"
}


feature_yq_3_1_2() {
	FEAT_VERSION="3_1_2"

	if [ "${STELLA_CURRENT_PLATFORM}" = "linux" ]; then
		FEAT_BINARY_URL_x86="https://github.com/mikefarah/yq/releases/download/3.1.2/yq_linux_386"
		FEAT_BINARY_URL_FILENAME_x86="yq_linux_386_${FEAT_VERSION}"
		FEAT_BINARY_URL_PROTOCOL_x86="HTTP"
		FEAT_BINARY_URL_x64="https://github.com/mikefarah/yq/releases/download/3.1.2/yq_linux_amd64"
		FEAT_BINARY_URL_FILENAME_x64="yq_linux_amd64_${FEAT_VERSION}"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP"

	fi
	if [ "${STELLA_CURRENT_PLATFORM}" = "darwin" ]; then
		FEAT_BINARY_URL_x86="https://github.com/mikefarah/yq/releases/download/3.1.2/yq_darwin_386"
		FEAT_BINARY_URL_FILENAME_x86="yq_darwin_386_${FEAT_VERSION}"
		FEAT_BINARY_URL_PROTOCOL_x86="HTTP"
		FEAT_BINARY_URL_x64="https://github.com/mikefarah/yq/releases/download/3.1.2/yq_darwin_amd64"
		FEAT_BINARY_URL_FILENAME_x64="yq_darwin_amd64_${FEAT_VERSION}"
		FEAT_BINARY_URL_PROTOCOL_x64="HTTP"
	fi

	FEAT_INSTALL_TEST="${FEAT_INSTALL_ROOT}"/yq
	FEAT_SEARCH_PATH="${FEAT_INSTALL_ROOT}"

}


feature_yq_install_binary() {

	__get_resource "${FEAT_NAME}" "${FEAT_BINARY_URL}" "${FEAT_BINARY_URL_PROTOCOL}" "${FEAT_INSTALL_ROOT}" "DEST_ERASE STRIP FORCE_NAME $FEAT_BINARY_URL_FILENAME"

	mv "${FEAT_INSTALL_ROOT}/${FEAT_BINARY_URL_FILENAME}" "${FEAT_INSTALL_ROOT}/yq"
	chmod +x "${FEAT_INSTALL_ROOT}/yq"

}


fi
