if [ ! "$_STELLA_COMMON_APP_INCLUDED_" == "1" ]; then 
_STELLA_COMMON_APP_INCLUDED_=1




# APP RESSOURCES & ENV MANAGEMENT ---------------

function __get_active_path() {
	echo "$PATH"
}

# ARG 1 optional : specify an app path
# return properties file path
function __select_app() {
	local _app_path=$1

	local _properties_file=

	if [ "$_app_path" == "" ]; then
		_app_path=$STELLA_CURRENT_RUNNING_DIR
	fi

	if [ -f "$_app_path/$STELLA_APP_PROPERTIES_FILENAME" ]; then
		_properties_file="$_app_path/$STELLA_APP_PROPERTIES_FILENAME"
		#STELLA_APP_ROOT=$_app_path
	fi
	
	echo "$_properties_file"
}


function __create_app_samples() {
	local _approot=$1

	cp -f "$STELLA_TEMPLATE/sample-app.sh" "$_approot/sample-app.sh"
	chmod +x $_approot/sample-app.sh

	cp -f "$STELLA_TEMPLATE/sample-stella.properties" "$_approot/sample-stella.properties"
}

function __link_app() {
	local _approot=$1
	local _stella_root=$2

	_approot=$(__rel_to_abs_path $_approot $STELLA_CURRENT_RUNNING_DIR)

	[ "$_stella_root" == "" ] && _stella_root=$STELLA_ROOT
	_stella_root=$(__abs_to_rel_path "$_stella_root" "$_approot")

	echo "#!/bin/bash" >$_approot/stella-link.sh.temp
	echo "_STELLA_LINK_CURRENT_FILE_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" >>$_approot/stella-link.sh.temp
	echo "export STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/$_stella_root" >>$_approot/stella-link.sh.temp

	cat $_approot/stella-link.sh.temp $STELLA_TEMPLATE/sample-stella-link.sh > $_approot/stella-link.sh
	chmod +x $_approot/stella-link.sh
	rm -f $_approot/stella-link.sh.temp

}

function __init_app() {
	local _app_name=$1
	local _approot=$2
	local _workroot=$3
	local _cachedir=$4


	if [ "$(__is_abs "$_approot")" == "FALSE" ]; then
		mkdir -p $STELLA_CURRENT_RUNNING_DIR/$_approot
		_approot=$(__rel_to_abs_path "$_approot" "$STELLA_CURRENT_RUNNING_DIR")
	else
		mkdir -p $_approot
	fi


    [ "$_workroot" == "" ] && _workroot=$_approot/workspace    
  	[ "$_cachedir" == "" ] && _cachedir=$_approot/cache


	[ "$(__is_abs "$_workroot")" == "FALSE" ] && _workroot=$(__rel_to_abs_path "$_workroot" "$_approot")
	[ "$(__is_abs "$_cachedir")" == "FALSE" ] && _cachedir=$(__rel_to_abs_path "$_cachedir" "$_approot")
	[ "$(__is_abs "$_stella_root")" == "FALSE" ] && _stella_root=$(__rel_to_abs_path "$STELLA_ROOT" "$_approot")

	_workroot=$(__abs_to_rel_path "$_workroot" "$_approot")
	_cachedir=$(__abs_to_rel_path "$_cachedir" "$_approot")
	_stella_root=$(__abs_to_rel_path "$STELLA_ROOT" "$_approot")

	echo "#!/bin/bash" >$_approot/stella-link.sh.temp
	echo "_STELLA_LINK_CURRENT_FILE_DIR=\"\$( cd \"\$( dirname \"\${BASH_SOURCE[0]}\" )\" && pwd )\"" >>$_approot/stella-link.sh.temp
	echo "export STELLA_ROOT=\$_STELLA_LINK_CURRENT_FILE_DIR/$_stella_root" >>$_approot/stella-link.sh.temp
	
	cat $_approot/stella-link.sh.temp $STELLA_TEMPLATE/sample-stella-link.sh > $_approot/stella-link.sh
	chmod +x $_approot/stella-link.sh
	rm -f $_approot/stella-link.sh.temp

	_STELLA_APP_PROPERTIES_FILE="$_approot/$STELLA_APP_PROPERTIES_FILENAME"
	if [ -f "$_STELLA_APP_PROPERTIES_FILE" ]; then
		echo " ** Properties file already exist"
	else
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_NAME" "$_app_name"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_WORK_ROOT" "$_workroot"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_CACHE_DIR" "$_cachedir"
		#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "DATA_LIST"
		#__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "ASSETS_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "ENV_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "INFRA_LIST"
		__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST"
	fi
}

# extract APP properties
function __get_all_properties() {
	local _properties_file=$1

	if [ -f "$_properties_file" ]; then

		# STELLA VARs
		__get_key "$_properties_file" "STELLA" "APP_NAME" "PREFIX"
		__get_key "$_properties_file" "STELLA" "APP_WORK_ROOT" "PREFIX"
		# so that nested stella application will use the same cache folder
		[ "$STELLA_APP_CACHE_DIR" == "" ] && __get_key "$_properties_file" "STELLA" "APP_CACHE_DIR" "PREFIX"
		#__get_key "$_properties_file" "STELLA" "DATA_LIST" "PREFIX"
		#__get_key "$_properties_file" "STELLA" "ASSETS_LIST" "PREFIX"
		__get_key "$_properties_file" "STELLA" "ENV_LIST" "PREFIX"
		__get_key "$_properties_file" "STELLA" "INFRA_LIST" "PREFIX"
		__get_key "$_properties_file" "STELLA" "APP_FEATURE_LIST" "PREFIX"

		#__get_data_properties "$_properties_file" "$STELLA_DATA_LIST"
		#__get_assets_properties "$_properties_file" "$STELLA_ASSETS_LIST"
		__get_infra_properties "$_properties_file" "$STELLA_INFRA_LIST"
		__get_env_properties "$_properties_file" "$STELLA_ENV_LIST"
	fi
}

function __get_data_properties() {
		local _properties_file=$1
		local _list=$2

		if [ -f "$_properties_file" ]; then

			# DATA
			for a in $_list; do
				__get_key "$_properties_file" "$a" DATA_NAMESPACE "PREFIX"
				__get_key "$_properties_file" "$a" DATA_ROOT "PREFIX"
				__get_key "$_properties_file" "$a" DATA_OPTIONS "PREFIX"
				__get_key "$_properties_file" "$a" DATA_NAME "PREFIX"
				__get_key "$_properties_file" "$a" DATA_URI "PREFIX"
				__get_key "$_properties_file" "$a" DATA_GET_PROTOCOL "PREFIX"
			done
		fi
}

function __get_assets_properties() {
	local _properties_file=$1
	local _list=$2

	if [ -f "$_properties_file" ]; then

		# ASSETS
		for a in $_list; do
			__get_key "$_properties_file" "$a" ASSETS_MAIN_PACKAGE "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_OPTIONS "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_NAME "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_URI "PREFIX"
			__get_key "$_properties_file" "$a" ASSETS_GET_PROTOCOL "PREFIX"
		done
	fi
}

function __get_infra_properties() {
	local _properties_file=$1
	local _list=$2

	if [ -f "$_properties_file" ]; then

		# INFRA
		for a in $_list; do
			__get_key "$_properties_file" "$a" INFRA_NAME "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_DISTRIB "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_CPU "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_MEM "PREFIX"
		done
	fi
}

# NOTE : call __get_infra_properties first
function __get_env_properties() {
	local _properties_file=$1
	local _list=$2

	if [ -f "$_properties_file" ]; then
		# ENV
		for a in $_list; do
			__get_key "$_properties_file" "$a" ENV_NAME "PREFIX"
			__get_key "$_properties_file" "$a" INFRA_ID "PREFIX"
		done

		# INFRA-ENV
		for a in $_list; do
			_artefact_infra_id="$a"_INFRA_ID
			_artefact_infra_id=${!_artefact_infra_id}
			# eval "$a"_INFRA_ID=$_artefact_infra_id
			if [ "$_artefact_infra_id" == "current" ]; then
				eval "$a"_OS=\$STELLA_CURRENT_OS
				eval "$a"_PLATFORM=\$STELLA_CURRENT_PLATFORM
				eval "$a"_PLATFORM_SUFFIX=\$STELLA_CURRENT_PLATFORM_SUFFIX
			else
				_artefact_distrib="$_artefact_infra_id"_INFRA_DISTRIB
				eval "$a"_DISTRIB=${!_artefact_distrib}
				eval "$a"_OS='$(__get_os_from_distro ${!_artefact_distrib})'
				eval "$a"_PLATFORM='$(__get_platform_from_os ${!_artefact_os})'
				_artefact_platform="$a"_PLATFORM
				eval "$a"_PLATFORM_SUFFIX='$(__get_platform_suffix ${!_artefact_platform})'
				_artefact_cpu="$_artefact_infra_id"_INFRA_CPU
				eval "$a"_CPU=${!_artefact_cpu}
				_artefact_mem="$_artefact_infra_id"_INFRA_MEM
				eval "$a"_MEM=${!_artefact_mem}
			fi
		done
	fi
}

function __remove_app_feature() {
	local _SCHEMA=$1

	__app_feature "REMOVE" $_SCHEMA
}

function __add_app_feature() {
	local _SCHEMA=$1

	__app_feature "ADD" $_SCHEMA
}

function __app_feature() {
	# ADD or REMOVE
	local _MODE=$1
	local _SCHEMA=$2
	local _APP_FEATURE_LIST=

	local _flag=0

	__translate_schema $_SCHEMA "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR" "_TR_FEATURE_OS_RESTRICTION"


	if [ -f "$_STELLA_APP_PROPERTIES_FILE" ]; then

		if [ "$STELLA_APP_FEATURE_LIST" == "" ]; then
			[ "$_MODE" == "ADD" ] && _APP_FEATURE_LIST="$_APP_FEATURE_LIST $_SCHEMA"
		else

			for f in $STELLA_APP_FEATURE_LIST; do

				__translate_schema $f "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION"


				if [ "$_TR_FEATURE_OS_RESTRICTION" == "$TR_FEATURE_OS_RESTRICTION" ]; then
					if [ "$_TR_FEATURE_VER" == "$TR_FEATURE_VER" ]; then
						if [ "$_TR_FEATURE_NAME" == "$TR_FEATURE_NAME" ]; then
							if [ "$_TR_FEATURE_ARCH" == "$TR_FEATURE_ARCH" ]; then
								if [ "$_TR_FEATURE_FLAVOUR" == "$TR_FEATURE_FLAVOUR" ]; then
									_flag=1
								fi
							fi
						fi
					fi
				fi
				if [ "$_MODE" == "REMOVE" ]; then
					[ ! "$_flag" == "1" ] && _APP_FEATURE_LIST="$_APP_FEATURE_LIST $f"
					_flag=0
				fi
				[ "$_MODE" == "ADD" ] && _APP_FEATURE_LIST="$_APP_FEATURE_LIST $f"
			done

			if [ "$_MODE" == "ADD" ]; then
				# This is a new feature
				if [ "$_flag" == "0" ]; then
					_APP_FEATURE_LIST="$_APP_FEATURE_LIST $_SCHEMA"
				fi
			fi
		fi

		_APP_FEATURE_LIST=$(echo $_APP_FEATURE_LIST | sed -e 's/^ *//' -e 's/ *$//')
		STELLA_APP_FEATURE_LIST=$(echo $STELLA_APP_FEATURE_LIST | sed -e 's/^ *//' -e 's/ *$//')

		if [ ! "$STELLA_APP_FEATURE_LIST" == "$_APP_FEATURE_LIST" ]; then
			__add_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "APP_FEATURE_LIST" "$_APP_FEATURE_LIST"
			# refresh value
			STELLA_APP_FEATURE_LIST=$_APP_FEATURE_LIST
		fi
	fi
}


function __get_features() {
	__feature_install_list "$STELLA_APP_FEATURE_LIST"
}

# install a feature listed in app feature list. Look for matching version in app feature list, so could match several version
function __get_feature() {
	local _SCHEMA=$1

	local _flag=0

	__translate_schema $_SCHEMA "_TR_FEATURE_NAME" "_TR_FEATURE_VER" "_TR_FEATURE_ARCH" "_TR_FEATURE_FLAVOUR" "_TR_FEATURE_OS_RESTRICTION"

	if [ ! "$STELLA_APP_FEATURE_LIST" == "" ]; then
		
		for f in $STELLA_APP_FEATURE_LIST; do

			__translate_schema $f "TR_FEATURE_NAME" "TR_FEATURE_VER" "TR_FEATURE_ARCH" "TR_FEATURE_FLAVOUR" "TR_FEATURE_OS_RESTRICTION"

			_flag=1
			[ ! "$_TR_FEATURE_NAME" == "$TR_FEATURE_NAME" ] && _flag=0
			[ ! "$_TR_FEATURE_FLAVOUR" == "" ] && [ ! "$_TR_FEATURE_FLAVOUR" == "$TR_FEATURE_FLAVOUR" ] && _flag=0
			[ ! "$_TR_FEATURE_ARCH" == "" ] && [ ! "$_TR_FEATURE_ARCH" == "$TR_FEATURE_ARCH" ] && _flag=0
			[ ! "$_TR_FEATURE_VER" == "" ] && [ ! "$_TR_FEATURE_VER" == "$TR_FEATURE_VER" ] && _flag=0

			
			if [ "$_flag" == "1" ]; then
				__feature_install $f
			fi
		done
	fi

}





# get a list of data by id
function __get_data() {
	local _list_id=$1
	__app_resources "DATA" "GET" "$_list_id"
}

# get a list of assets by id
function __get_assets() {
	local _list_id=$1
	mkdir -p "$ASSETS_ROOT"
	mkdir -p "$ASSETS_REPOSITORY"

	__app_resources "ASSETS" "GET" "$_list_id"
}

function __delete_data() {
	local _list_id=$1
	__app_resources "DATA" "DELETE" "$_list_id"
}

function __delete_assets() {
	local _list_id=$1
	__app_resources "ASSETS" "DELETE" "$_list_id"
}

function __update_data() {
	local _list_id=$1
	__app_resources "DATA" "UPDATE" "$_list_id"
}

function __update_assets() {
	local _list_id=$1
	__app_resources "ASSETS" "UPDATE" "$_list_id"
}

function __revert_data() {
	local _list_id=$1
	__app_resources "DATA" "REVERT" "$_list_id"

}

function __revert_assets() {
	local _list_id=$1
	__app_resources "ASSETS" "REVERT" "$_list_id"
}


function __get_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__get_data "$_list_pack"
}

function __get_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__get_assets "$_list_pack"
}

function __delete_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__delete_data "$_list_pack"
}

function __delete_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__delete_assets "$_list_pack"
}

function __update_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__update_data "$_list_pack"
}

function __update_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__update_assets "$_list_pack"
}

function __revert_data_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__revert_data "$_list_pack"
}

function __revert_assets_pack() {
	local _list_name=$1

	__get_key "$_STELLA_APP_PROPERTIES_FILE" "STELLA" "$_list_name" ""

	local _list_pack="$(eval echo "$"$(echo $_list_name))"
	__revert_assets "$_list_pack"
}

# ARG1 resource mode is DATA or ASSET
# ARG2 operation is GET or UPDATE or REVERT or DELETE (UPDATE or REVERT if applicable)
# ARG3 list of resource ID
function __app_resources() {
	local _mode=$1
	local _operation=$2
	local _list_id=$3

	if [ "$_mode" == "DATA" ]; then
		__get_data_properties "$_STELLA_APP_PROPERTIES_FILE" "$_list_id"
	fi

	if [ "$_mode" == "ASSETS" ]; then
		__get_assets_properties "$_STELLA_APP_PROPERTIES_FILE" "$_list_id"
	fi

	for a in $_list_id; do
		_artefact_namespace="$a"_"$_mode"_NAMESPACE
		_artefact_namespace=${!_artefact_namespace}
		
		_artefact_link=0
		if [ "$_mode" == "DATA" ]; then
			_artefact_root="$a"_"$_mode"_ROOT
			_artefact_root=${!_artefact_root}
			_artefact_dest=$(__rel_to_abs_path "$_artefact_root" "$STELLA_APP_WORK_ROOT")
			_artefact_link=0; 
		fi
		if [ "$_mode" == "ASSETS" ]; then _artefact_dest="$ASSETS_REPOSITORY"; _artefact_link=1; _artefact_link_target="$ASSETS_ROOT"; fi
		

		_opt="$a"_"$_mode"_OPTIONS
		_opt=${!_opt}
		_uri="$a"_"$_mode"_URI
		_uri=${!_uri}
		_prot="$a"_"$_mode"_GET_PROTOCOL
		_prot=${!_prot}
		_name="$a"_"$_mode"_NAME
		_name=${!_name}

		if [ "$_name" == "" ]; then
			echo "** Error : $a does not exist"
		fi

		_merge=
		for o in $_opt; do 
			[ "$o" == "MERGE" ] && _merge=MERGE
		done


		echo "* $_operation $_name [$a] resources"

		if [ "$_merge" == "MERGE" ]; then 
			echo "* Main package of [$a] is $_artefact_namespace"
		fi

		
		__resource "$_mode : $_name [$_artefact_namespace]" "$_uri" "$_prot" "$_artefact_dest/$_artefact_namespace" "$_opt $_operation"
		if [ "$_merge" == "MERGE" ]; then echo "* $_name merged into $_artefact_namespace"; fi
		if [ "$_artefact_link" == "1" ]; then
			if [ "$FORCE" == "1" ]; then rm -f "$_artefact_link_target/$_artefact_namespace"; fi
			[ ! -L "$_artefact_link_target/$_artefact_namespace" ] && (
				echo "** Make symbolic link for $_artefact_namespace"
				ln -s "$_artefact_dest/$_artefact_namespace" "$_artefact_link_target/$_artefact_namespace"
			)
		fi
	
	done
}

# VIRTUAL MANAGEMENT ---------------------------
function __setup_all_env() {
	__setup_env $STELLA_ENV_LIST
}

function __setup_env() {
	local _list_id=$1
	
	for a in $_list_id; do
		_env_infra_id="$a"_INFRA_ID
		_env_infra_id=${!_env_infra_id}
		_env_distrib="$a"_DISTRIB
		_env_distrib=${!_env_distrib}
		_env_os="$a"_OS
		_env_os=${!_env_os}
		_env_name="$a"_ENV_NAME
		_env_name=${!_env_name}
		_env_cpu="$a"_CPU
		_env_cpu=${!_env_cpu}
		_env_mem="$a"_MEM
		_env_mem=${!_env_mem}


		if [ ! "$_env_infra_id" == "current" ]; then
			echo" * Setting up env '$_env_name [$a]' with infra '[$_env_infra_id]' - using $_env_cpu cpu and $_env_mem Mo - built with '$_env_distrib', a $_env_os operating system"

			$STELLA_BIN/virtual.sh get-box $_env_distrib
			$STELLA_BIN/virtual.sh create-box $_env_distrib
			$STELLA_BIN/virtual.sh create-env $a#$_env_distrib --vcpu=$_env_cpu --vmem=$_env_mem

			echo " * Now you can use your env using $STELLA_BIN/virtual.sh OR with Vagrant"
		else
			echo "* Env '$_env_name [$a]' is the default current system"
		fi
	done

	
}




function __ask_install_requirements() {
	echo "Do you wish to auto-install requirements for stella (may ask for sudo password)?"
	select yn in "Yes" "No"; do
	    case $yn in
	        Yes )
				__stella_requirement
				break;;
	        No ) break;;
	    esac
	done
}

function __ask_init_app() {
		echo "Do you wish to init your stella app (create properties files, link app to stella...) ?"
		select yn in "Yes" "No"; do
		    case $yn in
		        Yes )
					_project_name=$(basename $STELLA_CURRENT_RUNNING_DIR)
					read -p "What is your project name ? [$_project_name]" _temp_project_name
					if [ ! "$_temp_project_name" == "" ]; then
						_project_name=$_temp_project_name
					fi

					echo "Do you wish to generate a sample app for your project ?"
					select sample in "Yes" "No"; do
						case $sample in
							Yes )
								# using default values for app paths (because we didnt ask them)
								__init_app $_project_name $STELLA_CURRENT_RUNNING_DIR
								__create_app_samples $STELLA_CURRENT_RUNNING_DIR
								break;;
							No )
								__init_app $_project_name $STELLA_CURRENT_RUNNING_DIR
								break;;
						esac
					done
					break;;

		        No ) break;;
		    esac
		done
}


fi