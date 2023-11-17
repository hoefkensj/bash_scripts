#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d                        AUTHOR: Hoefkens.J@gmail.com #
# # FILE: sourcepath.sh                                     0v99 - 2023.1.10 #
# ############################################################################
#\
function sourcepath { 	
	local VERSION="0.99"
	local WARNING="WARNING: This File Needs to be Sourced not Executed ! ";
	local ASK CASE SELECTED I;
	local HELP="""${FUNCNAME[0]} [-h]|[-iqd] [DIR] [MATCH]

ARGS:

    <DIR>             Directory to source files from.

    <MATCH>           Regex to match Files against. Globbing and Expansion follow Bash Settings

OPTIONS:

    -h   --help       Show this help text
    -i   --nocase     Ignore Case when matching
    -q   --quiet      Quiet/Silent/Script, Dont produce any output
    -d   --debug      Enable xtrace for this script
    -w   --warning    Shows $WARNING

EXAMPLES:

    Source files in ~/.config/bashrc/ that end in '.bashrc'
        ...and (-q) do not produce any output:
    
        sourcedir -q ~/.config/bashrc/ '.*\.bashrc'

    Source all files in '.env' starting with "config" case insensitive
        ...this inlcudes 'CONFIG.cfg' 'conFig.conf' but not 'mycfg.config'
    
        sourcedir -i .env '^config.*' 
    
    Source all files in '~/.bash_aliasses/' starting with 2 numbers,
        ...followed by an '_'. this matches '00_file.alias' but not '99file'
    
        sourcedir ~/.bash_aliasses/ '\/[0-9]{2}_.*$'  : 

DEFAULTS:

    -MATCH: '/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$' 
    -DIR: '\$PWD'

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
		[[ -z "$( which bat )" ]] && echo "$@"  | $( printf '%s' "$(which cat)"  ) 
		unset -f _bat
	};

	function _main (){ 

		function _sourcefiles () { 
			function _sourcefile ()	{ 
				local SUCCESS FILEN 
				[[ -z "$ERRN" ]] && ERRN= 0
				FILEN="$2"
				FILEN=$((FILEN-ERRN))
				source "$1" &>/dev/null 
				SUCCESS="$?"
				[[ "$SUCCESS" == "0" ]] && _progress "$1" "$GC" 2 "$2" 
				[[ "$SUCCESS" != "0" ]] && printf $1 && _failfile "$1" 
			};
			function _failfile() {
				ERRN=$((ERRN+1))
 				printf '\x1b[%sE' $ERRN #newline
 				_mask 0 "$GP" "$GS" "$GN" "$N" 1 1 "Failed  :" #mask
 				_progress "$1" "$GC" 1 "$ERRN"
 				printf '\x1b[%sF' $ERRN #newline
			};
			for CONF in $SELECTED;
			do
				I=$((I+1));
				[[ -e "$CONF" ]] && _sourcefile "$CONF" "$I" ;
			done
		};
		function _m () {
			#ANSI_m : ansi markup
			#~       ANSIESC [$1:INT] ; [$2:INT] m [$3:STRING] ANSIESCm (:resets to default)
			printf "\x1b[%s;3%sm%s\x1b[m" "$1" "$2" "$3"
		};
		function _G () {
			#ANSI_G : ansi cursor to column on current line
			#~       ANSIESC [$1:INT] G
			printf "\x1b[%sG" "$1"
		};
		function _Gm () {
		 	# COMBINES G (linepos) and m (markup)
			# printf statements are not needed here as they are in the functions
			#~printf  ANSIESC $1 G ANSIESC $2 ; $3 m $4 ANSIESC m
			_G "$1"; 
			_m "$2" "$3" "$4" ;
			#~	ANSIESC [$1:INT] G ANSIESC [$2:INT] ; [$3:INT] m [$4:STRING] ANSIESC m
			#	_Gm printf "\x1b[%sG\x1b[%s;%sm%s\x1b[m" "$1" "$2" "$3" "$4"
		};
		function _mask () {
			#   |  G |  m | string
			_Gm "${1}" "${6}" "${7}" "${8}";
			_Gm "${2}" 1 7 "[";
			_Gm "${3}" 1 7 "/";
			_Gm "${4}" 1 2 "${5}";
			_m 1 7 "]"
		};
		function _progress () { 
			#~	 G   m  m   STRING
			local toprint
			toprint=$1
			while true  ; do
				[[ ${#toprint} > 50 ]]  && toprint=".../${toprint#*/*/}" 
				[[ ${#toprint} < 50 ]]  && toprint="$toprint "
				[[ ${#toprint} == 50 ]]  && break;
			done		
			_Gm  12  1  3   "$toprint  "
			_Gm "$2" 1 "$3" "$4" 
			_G 80
		};		
		
		local MATCH SRC N W GP GS GC GN ERRN FILEN SELECTED ;
		
		SRC=$(realpath "${1}");
		[[ -n "$2" ]] && MATCH="$2" || MATCH='/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$';
		I=0;
		SELECTED=$( find "$SRC" 2>/dev/null |grep $CASE -E "$MATCH" );
		[[ -n "$SELECTED" ]] && N=$( echo "$SELECTED" |wc -l );
		W="${#N}";
		GP=$((80-10-W*2))
		GC=$((GP+1))
		GS=$((GP+W+1))
		GN=$((GP+W+2))
		ERRN=0
		_mask 0 "$GP" "$GS" "$GN" "$N" 0 7 "Sourcing:";
		_sourcefiles ;
		_mask 0 "$GP" "$GS" "$GN" "$N" 0 7 "Sourced :";
		_progress "$SRC" "$GC" 2 
		_Gm "$((80-5))" 1 32 "DONE"
		[[ "ERRN" != 0 ]] && printf '\x1b[E'
		echo
	};
	function sourcepath_cli() {

		case "$1" in 
			-h | --help | '')
				batcat help "$HELP" 2>>/dev/null
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
			-a | --ask)
				shift 1 && ASK=1 && ${FUNCNAME[0]} "$@"
			;;
			-w | --warning)
					batcat  help  "\x1b[1;31m$WARNING" >> /dev/stderr
			;;
			*)
				_main "$@"
			;;
		esac;
	};
	sourcepath_cli $@
	unset -f batcat _main  _sourcefiles  _m _G _progress _mask _state sourcepath_cli
}
#make sure its sourced not executed
(return 0 2>/dev/null) || sourcepath --warning