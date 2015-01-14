if [ ! "$_STELLA_COMMON_INCLUDED_" == "1" ]; then
_STELLA_COMMON_INCLUDED_=1

#turns off bash's hash function
set +h


# VARIOUS-----------------------------

# path = ${foo%/*}
# To get: /tmp/my.dir (like dirname)
# file = ${foo##*/}
# To get: filename.tar.gz (like basename)	
# base = ${file%%.*}
# To get: filename
# ext = ${file#*.}
# To get: tar.gz

function __get_path_from_string() {
	echo ${1%/*}
}

function __get_filename_from_string() {
	echo ${1##*/}
}

function __get_filename_from_url() {
	local _AFTER_SLASH
	_AFTER_SLASH=${1##*/}
	echo ${_AFTER_SLASH%%\?*}
}


function __is_abs() {
	local _path=$1

	case $_path in
		/*)
			echo "TRUE"
			;;
		*)
			echo "FALSE"
			;;
	esac
}

function __rel_to_abs_path() {
	local _rel_path=$1
	local _abs_root_path=$2


	case $_rel_path in
		/*)
			# path is already absolute
			echo "$_rel_path"
			;;
		*)
			# TODO if "$_abs_root_path" == "" then _abs_root_path=$_STELLA_CURRENT_RUNNING_DIR ?
			if [ "$_abs_root_path" == "" ]; then
				# relative to current path
				# TODO if directory does not exist returned path is not real absolute (example : /tata/toto/../titi instead of /tata/titi)
				if [ -d "$_rel_path" ]; then
					echo "$(cd "$_rel_path" && pwd )"
				else
					echo "$_rel_path"
				fi
			else
				# relative to a given absolute path
				if [ -d "$_abs_root_path/$_rel_path" ]; then
					echo "$(cd "$_abs_root_path/$_rel_path" && pwd )"
				else
					echo "$_abs_root_path/$_rel_path"
				fi
			fi
			;;
	esac
}


function __abs_to_rel_path() {
	
	local target="$1"
	local _abs_path="$2"
	local common_part=$_abs_path # for now

	local result=""

	case $_abs_path in
		/*)
			while [[ "${target#$common_part}" == "${target}" ]]; do
				# no match, means that candidate common part is not correct
				# go up one level (reduce common part)
				common_part="$(dirname $common_part)"
				# and record that we went back
				if [[ -z $result ]]; then
					result=".."
				else
					result="../$result"
				fi
				
			done

			if [[ $common_part == "/" ]]; then
				# special case for root (no common path)
				result="$result/"
			fi

			# since we now have identified the common part,
			# compute the non-common part
			forward_part="${target#$common_part}"
	
			if [[ -n $result ]] && [[ -n $forward_part ]]; then
				result="$result$forward_part"
			elif [[ -n $forward_part ]]; then
				result="${forward_part:1}"
			else
				do_nothing=1
			fi
			return_value=$result
			echo "$return_value"
			;;

		*)
			echo "$_abs_path"
			;;
	esac

}



function __init_stella_env() {
	__init_all_features
}



#FILE TOOLS----------------------------------------------
function __del_folder() {
	echo "** Deleting $1 folder"
	[ -d $1 ] && rm -Rf $1
}
# copy content of folder ARG1 into folder ARG2
function __copy_folder_content_into() {
	local filter=$3
	if [ "$filter" == "" ]; then
		filter="*"
	fi
	mkdir -p $2
	if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
		cp -R $1/$filter $2
	else
		cp -R $1/$filter --target-directory=$2
	fi
}

#DOWNLOAD AND ZIP FUNCTIONS---------------------------------------------------
function __get_ressource() {
	local NAME=$1
	local URI=$2
	local PROTOCOL=$3
	local FINAL_DESTINATION=$4
	local OPT="$5"
	# option should passed as one string "OPT1 OPT2"
	# 	"MERGE" for merge in FINAL_DESTINATION
	# 	"STRIP" for remove root folder and copy content of root folder in FINAL_DESTINATION
	# 	"UPDATE" pull and update ressource (only for HG or GIT)
	# 	"REVERT" complete revert of the ressource (only for HG or GIT)

	# TODO : remove illegal characters in NAME. NAME is used in flag file name when merging

	local _opt_merge=OFF
	local _opt_strip=OFF
	local _opt_get=ON
	local _opt_update=OFF
	local _opt_revert=OFF
	for o in $OPT; do 
		[ "$o" == "MERGE" ] && _opt_merge=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
		if [ "$o" == "UPDATE" ]; then _opt_update=ON;  _opt_revert=OFF;  _opt_get=OFF; fi
		if [ "$o" == "REVERT" ]; then _opt_revert=ON;  _opt_update=OFF;  _opt_get=OFF; fi
	done


	[ "$_opt_revert" == "ON" ] && echo " ** Reverting ressource :"
	[ "$_opt_update" == "ON" ] && echo " ** Updating ressource :"
	[ "$_opt_get" == "ON" ] && echo " ** Getting ressource :"
	[ ! "$FINAL_DESTINATION" == "" ] && echo " $NAME into $FINAL_DESTINATION" || echo " $NAME"

	[ "$FORCE" ] && rm -Rf $FINAL_DESTINATION

	# check if ressource already grabbed or merged
	_FLAG=1
	if [ "$_opt_merge" == "ON" ]; then
		if [ -f "$FINAL_DESTINATION/._MERGED_$NAME" ]; then
			if [ "$_opt_get" == "ON" ]; then
				_FLAG=0
				echo " ** Ressource already merged"
			fi
		else 
			if [ ! "$_opt_get" == "ON" ]; then
				_FLAG=0
				echo "** Ressource does not exist"
			fi
		fi
	else	
		if [ -d "$FINAL_DESTINATION" ]; then
			if [ "$_opt_get" == "ON" ]; then
				_FLAG=0
				echo " ** Ressource already grabbed"
			fi
		else
			if [ ! "$_opt_get" == "ON" ]; then
				_FLAG=0
				echo "** Ressource does not exist"
			fi
		fi

	fi

	# strip root folde mode
	_STRIP=
	[ "$_opt_strip" == "ON" ] && _STRIP=STRIP
	
	if [ "$_FLAG" == "1" ]; then
		[ ! -d $FINAL_DESTINATION ] && mkdir -p $FINAL_DESTINATION

		case $PROTOCOL in
			HTTP_ZIP)
				echo "MERGE : $_opt_merge"
				echo "STRIP : $_opt_strip"
				[ "$_opt_revert" == "ON" ] && echo "REVERT Not supported with HTTP_ZIP protocol"
				[ "$_opt_update" == "ON" ] && echo "UPDATE Not supported with HTTP_ZIP protocol"
				[ "$_opt_get" == "ON" ] && __download_uncompress "$URI" "_AUTO_" "$FINAL_DESTINATION" "$_STRIP"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			HTTP)
				echo "MERGE : $_opt_merge"
				# HTTP protocol use always merge by default : because it never erase destination folder
				# the flag file will be setted only if we pass the option MERGE
				[ "$_opt_revert" == "ON" ] && echo "REVERT Not supported with HTTP protocol"
				[ "$_opt_update" == "ON" ] && echo "UPDATE Not supported with HTTP protocol"
				[ "$_opt_get" == "ON" ] && __download "$URI" "_AUTO_" "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			HG)
				echo "MERGE : $_opt_merge"
				[ "$_opt_strip" == "ON" ] && echo "STRIP Not supported with HG protocol"
				if [ "$_opt_revert" == "ON" ]; then cd "$FINAL_DESTINATION"; hg revert --all -C; fi
				if [ "$_opt_update" == "ON" ]; then cd "$FINAL_DESTINATION"; hg pull; hg update; fi
				[ "$_opt_get" == "ON" ] && hg clone $URI "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			GIT)
				echo "MERGE : $_opt_merge"
				[ "$_opt_strip" == "ON" ] && echo "STRIP Not supported with GIT protocol"
				if [ "$_opt_revert" == "ON" ]; then cd "$FINAL_DESTINATION"; git reset --hard; fi
				if [ "$_opt_update" == "ON" ]; then cd "$FINAL_DESTINATION"; git pull; fi
				[ "$_opt_get" == "ON" ] && git clone $URI "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE)
				echo "MERGE : $_opt_merge"
				[ "$_opt_strip" == "ON" ] && echo "STRIP Not supported with FILE protocol"
				[ "$_opt_revert" == "ON" ] && echo "REVERT Not supported with FILE protocol"
				[ "$_opt_update" == "ON" ] && echo "UPDATE Not supported with FILE protocol"
				[ "$_opt_get" == "ON" ] && __copy_folder_content_into "$URI" "$FINAL_DESTINATION"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			FILE_ZIP)
				echo "MERGE : $_opt_merge"
				echo "STRIP : $_opt_strip"
				[ "$_opt_revert" == "ON" ] && echo "REVERT Not supported with FILE_ZIP protocol"
				[ "$_opt_update" == "ON" ] && echo "UPDATE Not supported with FILE_ZIP protocol"
				__uncompress "$URI" "$FINAL_DESTINATION%" "$_STRIP"
				[ "$_opt_merge" == "ON" ] && echo 1 > "$FINAL_DESTINATION/._MERGED_$NAME"
				;;
			*)
				echo " ** ERROR Unknow protocol"
				;;
		esac
	fi
}

function __download_uncompress() {
	local URL
	local FILE_NAME
	local UNZIP_DIR
	local OPT


	URL="$1"
	FILE_NAME="$2"
	UNZIP_DIR="$3"
	OPT="$4"
	
	local _opt_dest_erase=OFF # delete destination folder (default : FALSE)
	local _opt_strip=OFF # delete first folder in archive  (default : FALSE)
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
	done
	
	
	if [ "$FILE_NAME" == "_AUTO_" ]; then
		#_AFTER_SLASH=${URL##*/}
		FILE_NAME=$(__get_filename_from_url "$URL")
		echo "** Guessed file name is $FILE_NAME"
	fi
	
	__download $URL $FILE_NAME
	__uncompress "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$UNZIP_DIR" "$OPT"
}

function __uncompress() {
	local FILE_PATH
	local UNZIP_DIR
	local OPT
	FILE_PATH="$1"
	UNZIP_DIR="$2"
	OPT="$3"
	
	local _opt_dest_erase=OFF # delete destination folder (default : FALSE)
	local _opt_strip=OFF # delete first folder in archive  (default : FALSE)
	for o in $OPT; do 
		[ "$o" == "DEST_ERASE" ] && _opt_dest_erase=ON
		[ "$o" == "STRIP" ] && _opt_strip=ON
	done


	if [ "$_opt_dest_erase" == "ON" ]; then
		rm -Rf "$UNZIP_DIR"
	fi
	
	mkdir -p "$UNZIP_DIR"
	
	echo " ** Uncompress $FILE_PATH in $UNZIP_DIR"

	cd "$UNZIP_DIR"
	case "$FILE_PATH" in
		*.zip)
			[ "$_opt_strip" == "OFF" ] && unzip -a -o "$FILE_PATH"
			[ "$_opt_strip" == "ON" ] && __unzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*.gz | *.tgz) 
			[ "$_opt_strip" == "OFF" ] && tar xvf "$FILE_PATH"
			[ "$_opt_strip" == "ON" ] && tar xvf "$FILE_PATH" --strip-components=1
			;;
		*.xz | *.bz2)
			[ "$_opt_strip" == "OFF" ] && tar xvf "$FILE_PATH"
			[ "$_opt_strip" == "ON" ] && tar xvf "$FILE_PATH" --strip-components=1
			;;
		*.7z)
			[ "$_opt_strip" == "OFF" ] && 7z x "$FILE_PATH" -y -o"$UNZIP_DIR"
			[ "$_opt_strip" == "ON" ] && __sevenzip-strip "$FILE_PATH" "$UNZIP_DIR"
			;;
		*)
			echo " ** ERROR : Unknown archive format"
	esac
}

function __download() {
	local URL
	local FILE_NAME
	local DEST_DIR



	URL="$1"
	FILE_NAME="$2"
	DEST_DIR="$3"

	if [ "$FILE_NAME" == "" ]; then
		FILE_NAME="_AUTO_"
	fi

	if [ "$FILE_NAME" == "_AUTO_" ]; then
		#_AFTER_SLASH=${URL##*/}
		FILE_NAME=$(__get_filename_from_url "$URL")
		echo "** Guessed file name is $FILE_NAME"
	fi

	mkdir -p "$STELLA_APP_CACHE_DIR"

	echo " ** Download $FILE_NAME from $URL into cache"
	
	#if [ "$FORCE" == "1" ]; then
	#	rm -Rf "$STELLA_APP_CACHE_DIR/$FILE_NAME"
	#fi


	if [ ! -f "$STELLA_APP_CACHE_DIR/$FILE_NAME" ]; then
		if [ "$STELLA_CURRENT_PLATFORM" == "macos" ]; then
			curl -L -o "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$URL"
		else
			wget "$URL" -O "$STELLA_APP_CACHE_DIR/$FILE_NAME" --no-check-certificate
		fi
	else
		echo " ** Already downloaded"
	fi

	if [ ! "$DEST_DIR" == "" ]; then
		if [ ! "$DEST_DIR" == "$STELLA_APP_CACHE_DIR" ]; then
			if [ ! -d "$DEST_DIR" ]; then
				mkdir -p "$DEST_DIR"
			fi
			cp "$STELLA_APP_CACHE_DIR/$FILE_NAME" "$DEST_DIR/"
			echo "** Downloaded $FILE_NAME is in $DEST_DIR"
		fi
	fi
}

function __unzip-strip() (
    local zip=$1
    local dest=${2:-.}
    local temp=$(mktmpdir)

    unzip -a -o -d "$temp" "$zip"
    shopt -s dotglob 
    local f=("$temp"/*)
    
    if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
        mv "$temp"/*/* "$dest"
    else
        mv "$temp"/* "$dest"
    fi
    rm -Rf "$temp"
)

function __sevenzip-strip() (
    local zip=$1
    local dest=${2:-.}
    local temp=$(mktmpdir)
    7z x "$zip" -y -o"$temp"
    shopt -s dotglob 
    local f=("$temp"/*)
    
    if (( ${#f[@]} == 1 )) && [[ -d "${f[0]}" ]] ; then
        mv "$temp"/*/* "$dest"
    else
        mv "$temp"/* "$dest"
    fi
    rm -Rf "$temp"
)


# INI FILE MANAGEMENT---------------------------------------------------
function __get_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3
	local _OPT=$4

	# TODO : bug when reading windows end line
	# key will be prefixed with the section name
	_opt_section_prefix=OFF
	for o in $_OPT; do
		[ "$o" == "PREFIX" ] && _opt_section_prefix=ON
	done


	local _exp1="/\[$_SECTION\]/,/\[.*\]/p"
	local _exp2="/$_KEY=/{print \$2}"

	if [ "$_opt_section_prefix" == "ON" ]; then
		eval "$_SECTION"_"$_KEY"='$(sed -n "$_exp1" "$_FILE" | awk -F= "$_exp2")'
	else
		eval $_KEY='$(sed -n "$_exp1" "$_FILE" | awk -F= "$_exp2")'
	fi
}

function __del_key() {
	local _FILE=$1
	local _SECTION=$2
	local _KEY=$3

	__ini_file "DEL" "$_FILE" "$_SECTION" "$_KEY"
}

function __add_key() {
	local _FILE=$1 
	local _SECTION=$2
	local _KEY=$3
	local _VALUE=$4

	if [ ! -f "$_FILE" ]; then
		touch $_FILE
	fi

	__ini_file "ADD" "$_FILE" "$_SECTION" "$_KEY" "$_VALUE"
}

function __ini_file() {
	local _MODE=$1
	local _FILE=$2
	local _SECTION=$3
	local _KEY=$4
	if [ ! "$KEY" == "" ]; then
		local _VALUE=$5
	fi

	# escape regexp special characters
	# http://stackoverflow.com/questions/407523/escape-a-string-for-a-sed-replace-pattern
	_SECTION_NAME=$_SECTION
	_SECTION=$(echo $_SECTION | sed -e 's/[]\/$*.^|[]/\\&/g')

	tp=$(mktmp)

	awk -F= -v mode="$_MODE" -v val="$_VALUE" '
	# Clear the flag
	BEGIN {
		processing = 0;
		skip = 0;
		modified = 0;
	}

	# Entering the section, set the flag
	/^\['$_SECTION'/ {
		processing = 1;
	}
		
	# Modify the line, if the flag is set
	/^'$_KEY'=/ {
		if (processing) {
		   	if ( mode == "ADD" ) {
		   		print "'$_KEY'="val;
				skip = 1;
				modified = 1;
			}
		}
	}


	# Output a line (that we didnt output above)
	/.*/ {
		
		if (skip)
		    skip = 0;
		else
			print $0;
	}
	END {
		if(!modified && mode == "ADD") {
			if(!processing) print "['$_SECTION_NAME']"
			if("'$_KEY'" != "") {
				print "'$_KEY'="val;
		   	}
		}

	}

	' "$_FILE" > $tp

	mv -f $tp "$_FILE"
}



# ARG COMMAND LINE MANAGEMENT---------------------------------------------------
function __argparse(){
	local PROGNAME=$(__get_filename_from_string "$1")
	local OPTIONS="$2"
	local PARAMETERS="$3"
	local SHORT_DESCRIPTION="$4"
	local LONG_DESCRIPTION="$5"
	local COMMAND_LINE_RESULT="$6"
	shift 6
	
	local COMMAND_LINE="$@"
	
	ARGP="
	--HEADER--
	ARGP_PROG=$PROGNAME
	ARGP_DELETE=quiet verbose
	ARGP_VERSION=$STELLA_APP_NAME
	ARGP_OPTION_SEP=:
	ARGP_SHORT=$SHORT_DESCRIPTION
	ARGP_LONG_DESC=$LONG_DESCRIPTION"

	ARGP=$ARGP"
	--OPTIONS--
	$OPTIONS
	--PARAMETERS--
	$PARAMETERS
	"


	
	# Debug mode
	#export ARGP_DEBUG=1
	export ARGP_HELP_FMT=
	#export ARGP_HELP_FMT="rmargin=$(tput cols)"
	#echo $ARGP
	exec 4>&1 # fd4 is now a copy of fd1 ie stdout
	RES=$( echo "$ARGP" | $STELLA_COMMON/argp.sh $COMMAND_LINE 3>&1 1>&4 || echo exit $? ) 
	exec 4>&-

	# $@ now contains not parsed argument, options and identified parameters have been processed and removed:
	# echo "argp returned this for us to eval: '$RES'"
	[ "$RES" ] || exit 0

	eval $RES

	#echo "rest of command line : $@"
	
	if [ "$COMMAND_LINE_RESULT" ]; then
		eval "$COMMAND_LINE_RESULT=\$@"
	fi

	
}



fi