#!/usr/bin/env bash
# ############################################################################
# # PATH: /etc/profile.d                          AUTHOR: Hoefkens.J@gmail.com
# # FILE: bash_sourcedir.sh                                   0v6 - 2023.04.26
# ############################################################################
#
function bash_sourcedir { 	
	local VERSION="0.6"
	local WARNING="WARNING: This File Needs to be Sourced not Executed ! ";
	local HELP="
${FUNCNAME[0]} [-h]|[-qei] [DIR] [MATCH]

ARGS:

    <DIR>             Directory to source files from.

    <MATCH>           Regex to match Files against. Globbing and Expansion follow Bash Settings

OPTIONS:

    -h,  --help       Show this help text
    -i,  --nocase     Ignore Case when matching
    -q,  --quiet      Quiet/Silent/Script, Dont produce any output
    -d,  --debug      Enable xtrace for this script
         --warning    Shows $WARNING

RECOMENDED:

    Make Sourcedir availeble as a command:
    su -c 'cp -v ./sourcedir.sh /etc/profile.d/

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

    - MATCH: '/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$' 
    - DIR: '$PWD'

";
	# set -o errexit
	# set -o nounset
	local _help _warn
	function batcat () {
		local _cat _bat
		function _bat() {
			local theme lang paging batopts
			theme="Monokai Extended Origin"
			lang="$LANG"
			paging="never"
			batopts="--plain --paging=$paging --theme=$theme --language=$lang"
			bat "$batopts" <<< "$1"			
		}

		LANG="$1"
		shift 1
		STRING="$@"
		got_cat=$( which "cat" )
		got_bat=$( which "bat" )
		[[ -n "$got_bat" ]] &&  _bat "$STRING"
		[[ -z "$got_bat" ]] && echo $( printf '%s' "$@" ) | $( printf '%s' "$_cat"  ) 
	};	

	function _main ()  
	{ 
		local MATCH SRC N W GP GS GC GN ;
		function _sourcefiles () 
		{ 
			function _sourcefile () 			{ 
				source "$1" && _progress "$1" "$GC" 2 "$2"   || echo "" & _progress "$1" "$GC" 1 "$2" & echo ""
			};
			for CONF in $SELECTED;
			do
				I=$((I+1));
				[[ -e "$CONF" ]] && _sourcefile "$CONF" "$I" ;
			done
		};
		function _m () #ANSI_m : ansi markup
		{   #~       ANSIESC [$1:INT] ; [$2:INT] m [$3:STRING] ANSIESCm (:resets to default)
			printf "\x1b[%s;3%sm%s\x1b[m" "$1" "$2" "$3"
		};
		function _G () #ANSI_G : ansi cursor to column on current line
		{ 	#~       ANSIESC [$1:INT] G
			printf "\x1b[%sG" "$1"
		};
		function _Gm () # COMBINES G (linepos) and m (markup) 
		{ 	# printf statements are not needed here as they are in the functions
			#~printf  ANSIESC $1 G ANSIESC $2 ; $3 m $4 ANSIESC m
			_G "$1"; 
			_m "$2" "$3" "$4" ;
		#~	ANSIESC [$1:INT] G ANSIESC [$2:INT] ; [$3:INT] m [$4:STRING] ANSIESC m
		#	_Gm printf "\x1b[%sG\x1b[%s;%sm%s\x1b[m" "$1" "$2" "$3" "$4"
		};
		function _mask () 
		{ 		
			#   |  G |  m | string
			_Gm "${1}" 0 7 "Sourcing:";
			_Gm "${2}" 1 7 "[";
			_Gm "${3}" 1 7 "/";
			_Gm "${4}" 1 2 "${5}";
			_m 1 7 "]"
		};
		function _progress () 
		{ #~	 G   m  m   STRING
			local toprint
			toprint=$1
			while true  ; do
				[[ ${#toprint} > 50 ]]  && toprint=".../${toprint#*/*/}" 
				[[ ${#toprint} < 51 ]] && break ;
			done		
			_Gm  12  1  3   "$toprint"
			_Gm "$2" 1 "$3" "$4" 
			_G 80
		};		

		SRC=$(realpath "${1}");
		[[ -n "$2" ]] && MATCH="$2" || MATCH='/[0-9]+[_-]*.*\.(sh|bash|bashrc|rc|conf|cfg)$';
		I=0;
		SELECTED=$( find "$SRC" 2>/dev/null |grep -E "$MATCH" );
		[[ -n "$SELECTED" ]] && N=$( echo "$SELECTED" |wc -l );
		W="${#N}";
		GP=$((80-10-W*2))
		GC=$((GP+1))
		GS=$((GP+W+1))
		GN=$((GP+W+2))
		_mask 0 "$GP" "$GS" "$GN" "$N" ;
		_sourcefiles ;
		_Gm "$((80-5))" 1 32 "DONE"
		echo
		};
		local CASE SELECTED I;
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
			--warning)
					batcat  help  "\x1b[1;31m$WARNING" >> /dev/stderr
			;;
			*)
				_main "$@"
			;;
		esac;
		unset _m _G _progress _mask _state _sourcefiles _main _cat
}
#make sure its sourced not executed
(return 0 2>/dev/null) || sourcedir --warning