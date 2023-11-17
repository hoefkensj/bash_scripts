#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d                        AUTHOR: Hoefkens.J@gmail.com #
# # FILE: sourcepath.sh                                0v99 - 2023.05.22 #
# ############################################################################
#
function sourcepath {
	local EXENAME="sourcepath"
	local VERSION="0.66"
	local WARNING="WARNING: This File Needs to be Sourced not Executed ! ";
	local HELP="""${FUNCNAME[0]} [-h]|[-iqd] [DIR] [MATCH]

ARGS:

<DIR>             Directory to source files from.

<MATCH>           Regex to match Files against. Globbing and Expansion follow Bash Settings

OPTIONS:

-h   --help       Show this help text
-a   --ask        Ask so source before every match [Y/n]
-i   --nocase     Ignore Case when matching
-q   --quiet      Quiet/Silent/Script, Dont produce any output
-d   --debug      Enable xtrace for this script
-w   --warning    Shows $WARNING

DIR:
    First argument to the function, the path to the directory holding the files
    to be sourced into the current env. This folder is searched recursively.
    for Matches (see [MATCH])

MATCH:
    Second Argument to the function , is fed directly into 'grep -E ' for 
    matching filenames found in <DIR>, see [EXAMPLES] for common use cases.
    the string that is matched against is the full (real) path of the files
    
    WARNING: this is of consern if the dir you specified is a symlink or is
    in the subtree of a symlink. if you want to source all files ending in 
    "config" in a folder <~/myproj/user/> wich is a symlink to 
    /home/[username]/.config/myproj/, using a match regex of '.*config.*'
    wil match everyfile in the direcory allong with every file in potential 
    subdirectories , because 'config' is part of the real path of the directory -> 
    .../.config/..., you can test the paht used by running in your shell:
    realpath [path]
    wich would reveal the fully resolved path of [path] that is used to match against

EXAMPLES:

- Source files in ~/.config/bashrc/ that end in '.bashrc'
    ...and (-q) do not produce any output:

sourcedir -q ~/.config/bashrc/ '.*\.bashrc'

- Source all files in '.env' starting with "config" case insensitive
    ...this inlcudes 'CONFIG.cfg' 'conFig.conf' but not 'mycfg.config'

sourcedir -i .env '^config.*'

- Source all files in '~/.bash_aliasses/' starting with 2 numbers,
...followed by an '_'. this matches '00_file.alias' but not '99file'

sourcedir ~/.bash_aliasses/ '\/[0-9]{2}_.*$'  :

DEFAULTS:

-MATCH: '/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$'
-DIR: '$PWD'

(C) Hoefkens Jeroen
${FUNCNAME[0]} v ${VERSION}
""";
	# set -o errexit
	# set -o nounset
	# set -o xtrace

	function batcat () {
		function _bat() {
			local theme paging batopts
			theme="Monokai Extended Origin"
			paging="never"

			echo "$@" |bat  --plain --paging="$paging" --theme="$theme" --language="$lang"
		};
		local lang
		lang="$1"
		shift 1 #remove that from the args as cat doesnt need it
		[[ -n "$( which bat )" ]] &&   _bat "$@"
		[[ -z "$( which bat )" ]] && echo $( printf '%s' "$@" ) | $( printf '%s' "$(which cat)"  )
	};
	function bash_shorten_path() {
		local $_PATH $_LEN
		_PATH=$1
		_LEN=$2
		while true  ; do
			[[ ${#_PATH} >  $_LEN ]]  && _PATH=".../${_PATH#*/*/}" 
			[[ ${#_PATH} <  $_LEN ]]  && _PATH="${_PATH} "
			[[ ${#_PATH} == $_LEN ]]  && break;
		done
		printf '%s' "${_PATH}"	
	}
	function _main (){

		function _sourcefile () {
			source "$1" 2>/dev/null
			[[ $? -eq 0 ]] && printf 'true' || printf 'false'
		}
		function _sourcefiles () {
			local COUNT SUCCESS DONE FAIL SCONF
			DONE=0
			FAIL=0
			COUNT=0
			for CONF in $SELECTED;
			do
				COUNT=$((COUNT+1))
				SCONF="$( bash_shorten_path $CONF 50 )"
				[[ -e "$CONF" ]] && SUCCESS=$( _sourcefile "$CONF"  ) 2>/dev/null
				[[ "$SUCCESS" == "true" ]] && DONE=$((DONE +1 )) && print_progress $DONE $SCONF
				[[ "$SUCCESS" == "false" ]] && FAIL=$((FAIL +1 )) && print_fail $COUNT $SCONF $FAIL
			done
		 	print_progress $DONE "$( bash_shorten_path $SRC 50 )"
			Y=$((FAIL+2))
			printf '\x1b[%sE' "$Y"
		};

		function print_progress(){
			local I IW GC GL
			I=$1
			IW="${#I}";
			GC=$((GS-IW))
			CL=$((GC-1))
			printf $_Gm 1 1 7 "Sourced:" ;
			printf $_Gm 12 1 3 $2 ;
			printf $_Gm "$GL" 1 7 "[" ; 
			printf $_Gm "$GC" 0 2 "$1" ;
			printf $_Gm "$GS" 1 7 "/" ;
			printf $_Gm "$GN" 0 2 "$N" ;
			printf $_Gm "$GE" 1 7 "]" ;
		}
		function print_fail(){
			local I Y IW GF GL
			I=$1
			Y=$3
			IW="${#I}";
			GI=$((GE-IW))
			GL="$((GI-1))"
			printf '\x1b[%sE' $Y 
			printf $_Gm  1 0 1 "FAILED:";
			printf $_Gm  12 1 3 $2;
			printf $_Gm  "$GL" 0 7 "["; 
			printf $_Gm  "$GI" 1 1 "$I";
			printf $_Gm  "$GE" 0 7 "]";
			printf '\x1b[%sF' $Y 
		}

		local _m _Gm SRC SELECTED MATCH N C W GE GP GC GS GN
		_m='\x1b[%s;3%sm%s\x1b[m'
		_Gm="\x1b[%sG${_m}\x1b[G"
		SRC=$(realpath "${1}");
		[[ -n "$2" ]] && MATCH="$2" || MATCH='/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$';
		SELECTED=$( find "$SRC" 2>/dev/null |grep -E "$MATCH" );
		[[ -n "$SELECTED" ]] && N=$( echo "$SELECTED" |wc -l );
		[[ -n "$2" ]] && C=$2 || C=80
		W="${#N}";
		GE=$((C-1))
		GN=$((GE-W))
		GS=$((GN-1))

		_sourcefiles ;
	};

	function sourcepath_cli() {
		case "$1" in
			-h | --help | '')
				batcat help "$HELP"
				;;
			-d | --debug)
				shift && set -o xtrace && ${FUNCNAME[0]} "$@"
				;;
			-q | --quiet)
				shift 1 && ${FUNCNAME[0]} "$@" &> /dev/null
				;;
			-i | --nocase)
				shift 1 && CASE="-i" && ${FUNCNAME[0]} "$@"
				;;
			-w | --warning)
				batcat  help  "\x1b[1;31m$WARNING" >> /dev/stderr
				;;
			*)
				_main "$@"
				;;
		esac;
	} 
	sourcepath_cli "$@"
}

#make sure its sourced not executed
(return 0 2>/dev/null) || sourcepath --warningbash: bash_history: command not found