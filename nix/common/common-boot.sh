#!sh
if [ ! "$_STELLA_BOOT_INCLUDED_" = "1" ]; then
_STELLA_BOOT_INCLUDED_=1


# TODO : when booting a script, how pass arg to script ?
# TODO : take care of an optional boot_folder with something like [schema://][user[:password]@][host][:port][/abs_path|?rel_path][#boot_folder]

# [schema://][user[:password]@][host][:port][/abs_path|?rel_path]
# schema values
#     local:// (or just 'local')
#          (with local, host is never used. i.e : local:///abs_path local://?rel_path)
#     ssh://
#     vagrant://
#          (with vagrant, use vagrant machine name as host)



# When schema is 'ssh' or 'vagrant'
#     <path> is computed from default path when logging in ssh and then applying abs_path|rel_path
#     current folder is setted to <path>
#     When booting 'stella'
#         stella is sync with its env file in <path>/stella
#         stella requirements are installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell
#               'script' : script is sync in <path>/<script.sh> then launch the script
#               'cmd' : launch a cmd inside a bootstraped stella env
#     When booting an 'app'
#         app is sync in <path>/app
#         stella is sync with its env file accordingly to its position defined in stella-link file [only if stella is outside of app]
#         stella requirements are installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell, launched from app stella-link file
#               'script' : script is sync in <path>/<script.sh> then launch the script
#               'cmd' : launch a cmd (HERE : stella env is not bootstrapped!)


# When schema is 'local'
#     <path> is computed from current running path and then applying abs_path|rel_path
#            if abs_path|rel_path are not provided, then <path> is considered as NULL
#     current folder is setted to <path> [if <path> is not NULL]
#     When booting 'stella'
#         stella is sync with its env file in <path>/stella [if <path> is not NULL]
#         stella requirements are NOT installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell
#               'script' : script is sync in <path>/<script.sh> [if <path> is not NULL] then launch the script
#               'cmd' : launch a cmd inside a bootstraped stella env
#     When booting an 'app'
#         app is sync in <path>/app [if <path> is not NULL]
#         stella is sync with its env file accordingly to its position defined in stella-link file [only if stella is outside of app AND if <path> is not NULL]
#         stella requirements are NOT installed
#         When action is
#               'shell' : launch a shell with a bootstrapped stella env inside shell, launched from app stella-link file
#               'script' : script is sync in <path>/<script.sh> [if <path> is not NULL] then launch the script
#               'cmd' : launch a cmd (HERE : stella env is not bootstrapped!)


# SAMPLES
# from an app
# ./stella-link.sh boot shell vagrant://default
# ./stella-link.sh boot shell local
# from an stella
# ./stella.sh boot shell vagrant://default
# ./stella.sh boot shell local


# MAIN FUNCTION -----------------------------------------
__boot_stella_shell() {
  local _uri="$1"
  local _opt="$2"
  __boot "$_opt STELLA SHELL" "$_uri"
}
__boot_stella_cmd() {
  local _uri="$1"
  local _cmd="$2"
  local _opt="$3"
  __boot "$_opt STELLA CMD" "$_uri" "$_cmd"
}
__boot_stella_script() {
  local _uri="$1"
  local _script="$2"
  local _opt="$3"
  __boot "$_opt STELLA SCRIPT" "$_uri" "$_script"
}


__boot_app_shell() {
  local _uri="$1"
  local _opt="$2"
  __boot "$_opt APP SHELL" "$_uri"
}
__boot_app_cmd() {
  local _uri="$1"
  local _cmd="$2"
  local _opt="$3"
  __boot "$_opt APP CMD" "$_uri" "$_cmd"
}
__boot_app_script() {
  local _uri="$1"
  local _script="$2"
  local _opt="$3"
  __boot "$_opt APP SCRIPT" "$_uri" "$_script"
}





# INTERNAL -----------------------------------------


# ITEM : APP | STELLA
# MODE : SHELL | CMD | SCRIPT
# OTHER OPTIONS : SUDO
__boot() {
  local _opt="$1"
  local _uri="$2"
  local _arg="$3"

  local _mode=
  local _item=
  local _opt_sudo=
  local _opt_sudo_cmd=
  for o in $_opt; do
    [ "$o" = "SCRIPT" ] && _mode="SCRIPT"
    [ "$o" = "SHELL" ] && _mode="SHELL"
		[ "$o" = "CMD" ] && _mode="CMD"

		[ "$o" = "APP" ] && _item="APP"
    [ "$o" = "STELLA" ] && _item="STELLA"

		[ "$o" = "SUDO" ] && _opt_sudo="SUDO" && _opt_sudo_cmd="sudo "
	done

  local __have_to_transfer=0

  if [ "$_uri" = "local" ]; then
    # we do not have to transfer anything
    __have_to_transfer=0
    __stella_uri_schema="local"

  else
    # [schema://][user[:password]@][host][:port][/abs_path|?rel_path]
    __have_to_transfer=1

    __path="$(__uri_get_path "$_uri")"
    __uri_parse "$_uri"

    # TODO : dangerous tweak because it impacts the target OS.
    #       Maybe, use __ssh_sudo_begin_session only with an explicit option like --sudopersist
    [ ! "$_opt_sudo" = "" ] && __sudo_ssh_begin_session "$_uri"

    # boot stella itself
    if [ "$_item" = "STELLA" ]; then
      #__boot_folder="$__path"
      __stella_path="$__path/stella"
      __stella_entrypoint="$__stella_path/stella.sh"
      __transfer_stella "$_uri" "ENV $_opt_sudo"
    fi

    if [ "$_item" = "APP" ]; then
      # boot an app
      #__boot_folder="$__path"

      __transfer_app "$_uri" "$_opt_sudo"
      __app_path="$__path/$(basename "$STELLA_APP_ROOT")"
      #__stella_path="${__app_path}/$(__abs_to_rel_path "$STELLA_ROOT" "$STELLA_APP_ROOT")"
      __stella_entrypoint="${__app_path}/stella-link.sh"
    fi

    if [ "$_mode" = "SCRIPT" ]; then
      __script_filename="$(__get_filename_from_string $_arg)"
      __transfer_file_rsync "$_arg" "$_uri/$__script_filename" "$_opt_sudo"
      __script_path="$__path/$__script_filename"
    fi


  fi


  case $__stella_uri_schema in

    local )
      if [ "$__have_to_transfer" = "0" ]; then
        # local
        case $_mode in
          SHELL )
            __bootstrap_stella_env
            ;;
          CMD )
              eval "$_arg"
            ;;
          SCRIPT )
              "$_arg"
            ;;
        esac
      else
          #local://[/abs_path|?rel_path]
          case $_mode in
            SHELL )
               #cd $__boot_folder
               $__stella_entrypoint stella install dep
               $__stella_entrypoint boot shell local
              ;;
            CMD )
              #cd $__boot_folder
              $__stella_entrypoint stella install dep
              $__stella_entrypoint boot cmd local -- $_arg
              ;;
            SCRIPT )
              #cd $__boot_folder
              $__stella_entrypoint stella install dep
              $__script_path
              ;;
          esac
      fi
      ;;



    ssh|vagrant )
      #ssh://user@host:port[/abs_path|?rel_path]
      #vagrant://vagrant-machine[/abs_path|?rel_path]

      case $_mode in
        SHELL )
          #__ssh_execute "$_uri" "cd $__boot_folder && $__stella_entrypoint stella install dep && $__stella_entrypoint boot shell local" "SHARED"
          __ssh_execute "$_uri" "${_opt_sudo_cmd}$__stella_entrypoint stella install dep; ${_opt_sudo_cmd}$__stella_entrypoint boot shell local" "SHARED"
          ;;
        CMD )
          #__ssh_execute "$_uri" "cd $__boot_folder && $__stella_entrypoint stella install dep && $__stella_entrypoint boot cmd local -- '$_arg'" "SHARED"
          __ssh_execute "$_uri" "${_opt_sudo_cmd}$__stella_entrypoint stella install dep; ${_opt_sudo_cmd}$__stella_entrypoint boot cmd local -- '$_arg'" "SHARED"
          ;;
        SCRIPT )
          #__ssh_execute "$_uri" "cd $__boot_folder && $__stella_entrypoint stella install dep && $__script_path" "SHARED"
          __ssh_execute "$_uri" "${_opt_sudo_cmd}$__stella_entrypoint stella install dep; ${_opt_sudo_cmd}$__script_path" "SHARED"
          ;;
      esac
      [ ! "$_opt_sudo" = "" ] && __sudo_ssh_end_session "$_uri"
      ;;
    *)
      echo " ** ERROR uri protocol unknown"
      ;;

  esac

}


__bootstrap_stella_env() {
	export PS1="[stella] \u@\h|\W>"

	local _t=$(mktmp)
	#(set -o posix; set) >$_t
	declare >$_t
	declare -f >>$_t
( exec bash -i 3<<HERE 4<&0 <&3
. $_t 2>/dev/null;rm $_t;
echo "** STELLA SHELL with env var setted (type exit to exit...) **"
exec  3>&- <&4
HERE
)
}



fi
