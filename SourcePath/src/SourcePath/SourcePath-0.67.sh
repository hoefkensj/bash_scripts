#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d                        AUTHOR: Hoefkens.J@gmail.com #
# # FILE: SourcePath.sh                                    0v66 - 2024.01.07 #
# ############################################################################
#
function sourcepath {
	local EXENAME="sourcepath"
	local VERSION="0.66"
	local WARNING="WARNING: This File Needs to be Sourced not Executed ! ";
	local HELP="""'''
${FUNCNAME[0]} [-h]|[-iqd] [DIR] [MATCH]

ARGS:

<DIR>             Directory to source files from.

<MATCH>           Regex to match Files against. Globbing and Expansion follow Bash Settings

OPTIONS:

-h   --help       Show this help text
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
    the string that is matched against is the full (real) path of the filess


WARNING:

- GLOBBING
     globbing does not work for filenames appended to the dir.

I :  if you want to source all .sh files in ./bashrc/ :

sourcepath ~/.bashrc/*.sh     - this won't work!
sourcepath ~/.bashrc '*.sh$'  - this will:

- shell globbing does work in the path 
- shell globbing also works outside the '' of the regex <MATCH>

sourcepath ~/.env/*.d/ '*.sh$'
sourcepath ~/.env/bash.d/ '^[0-9]{2}'_*
 


EXAMPLES:
- Source files in ~/.config/bashrc/ that end in '.bashrc'
    ...and (-q) do not produce any output:

sourcepath -q ~/.config/bashrc/ '.*\.bashrc'

- Source all files in '.env' starting with 'config' , Case-Insensitive
    ...this inlcudes 'CONFIG.cfg' 'conFig.conf' but not 'mycfg.config'

sourcepath -i .env '^config.*'

- Source all files in '~/.bash_aliasses/' starting with 2 numbers,
...followed by an '_'. this matches '00_file.alias' but not '99file' or '.00_filea'

sourcepath ~/.bash_aliasses/ '\/[0-9]{2}_.*$'  :

DEFAULTS:

-MATCH: '/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$'
-DIR: '\$PWD'

gitrepo : github.com/hoefkensj/SourcePath (CC) Hoefkens Jeroen
${FUNCNAME[0]} v ${VERSION}
'''"""
	# set -o errexit
	# set -o nounset
	# set -o xtrace

	function _cleanup() {
		#functions:
		unset -f batcat _bat bash_shorten_path _main _sourcefile _sourcefiles print_progress print_fail _cleanup
	};

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
		local _PATH _LEN
		_BASE=$(basename $1)
		_DIR=$(dirname $1)
		_PATH=$_DIR
		_LEN=$2
		while true  ; do
			[[ ${#_PATH} > $_LEN ]]  && _PATH="${_PATH#*/*/}" 
			[[ ${#_PATH} < $_LEN ]]  && _PATH="${_PATH} "
			[[ ${#_PATH} == $_LEN ]]  && break;
			sleep 0.001
		done
		printf '%s%s' "$PFX" "${_PATH}"	

	};

	function _main (){

		function _sourcefile () {
			source "$1" 2>/dev/null
			[[ $? -eq 0 ]] && SUCCESS='true' || SUCCESS='false'
		};

		function _sourcefiles () {
			local COUNT SUCCESS DONE FAIL SCONF
			DONE=0
			FAIL=0
			COUNT=0
			for CONF in $SELECTED;
			do
				COUNT=$((COUNT+1))
				SCONF="$( bash_shorten_path $CONF 50 )"
				[[ -e "$CONF" ]] &&  _sourcefile "$CONF"  2>/dev/null
				[[ "$SUCCESS" == "true" ]] && DONE=$((DONE +1 )) && print_progress $DONE $SCONF
				[[ "$SUCCESS" == "false" ]] && FAIL=$((FAIL +1 )) && print_fail $COUNT $CONF $FAIL
			done
		 	print_progress $DONE $SSRC
			Y=$((FAIL+2))
			for ((i = 0 ; i <  Y ; i++)); do
  				printf '\n'
			done
		};

		function print_progress(){
			local I IW GC GL
			I=$1
			IW="${#I}";
			GC=$((GS-IW))
			GL=$((GC-1))
			printf $_Gm 1 1 7 "Sourced:" ;
			printf $_Gm 12 1 3 $2 ;
			printf $_Gm "$GL" 1 7 "[" ; 
			printf $_Gm "$GC" 0 2 "$1" ;
			printf $_Gm "$GS" 1 7 "/" ;
			printf $_Gm "$GN" 0 2 "$N" ;
			printf $_Gm "$GE" 1 7 "]" ;
		};

		function print_fail(){
			local I Y IW GF GL
			I=$1
			Y=$3
			IW="${#I}";
			GI=$((GE-IW))
			GL="$((GI-1))"

			for ((i = 0 ; i <  Y ; i++)); do
  				printf '\n'
			done
			printf $_Gm  1 0 1 "FAILED:";
			printf $_Gm  12 1 3 $2;
			printf $_Gm  "$GL" 0 7 "["; 
			printf $_Gm  "$GI" 1 1 "$I";
			printf $_Gm  "$GE" 0 7 "]";
			printf '\x1b[%sF' $Y 
		};

		local _m _Gm SRC SSRC SELECTED MATCH N C W GE GP GC GS GN SUCCESS
 		_m='\x1b[%s;3%sm%s\x1b[m'
		_Gm="\x1b[%sG${_m}\x1b[G"
		SRC=$(realpath "${1}");
		SSRC=$( bash_shorten_path "${SRC}" 47 )
		[[ -n "$2" ]] && MATCH="$2" || MATCH='/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$';
		SELECTED=$( find "$SRC" 2>/dev/null |grep -E $CASE "$MATCH" );
		[[ -n "$SELECTED" ]] && N=$( echo "$SELECTED" |wc -l );
		[[ -n "$3" ]] && C=$3 || C=80
		W="${#N}";
		GE=$((C-1))
		GN=$((GE-W))
		GS=$((GN-1))

		_sourcefiles ;
	};

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

	_cleanup
}

#make sure its sourced not executed
(return 0 2>/dev/null) || sourcepath --warning
