
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
				[[ "$SUCCESS" == "false" ]] && FAIL=$((FAIL +1 )) && print_fail $COUNT $SCONF $FAIL
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
