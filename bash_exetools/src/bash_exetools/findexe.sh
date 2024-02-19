#!/usr/bin/env bash
function _findexe(){
	HELP="""
use: $findexe   --help --list-duplicates -<#|t|c> --sep [separator] '<REGEX>'|[characters to match]

Bash search executables on this system. 

ARGS:
    --help                  Display this text
    --sep                   Separator to use with -t(wrap) defaults to '   ' (3 spaces)
    --list-duplicates       Do not filter out duplicate commands/binaries
    -#                      Display 1 Command per line
    -t                      Wrap all commands in a single line separated by --sep
    -c                      Columns, display commands in collumns (bug/broken)
    
EXAMPLES:
	
	findexe -# 'top$'       list all runnable things ending in the letters 'top' ,1 per line
	findexe -t --sep ',''   create a comma separated list(CSV) of all the possible commands on this system
	findexe s ctl           list all commands that have an s and  ctl (this would match sysctl systemdctl ,...)
"""

	function _findexs(){
		ARGS=$(echo "$@" | xargs printf -- '.*?%s') 
		compgen -A function -bcak | grep  -Ei "$ARGS.*?\$" 
	}
 	function _item(){
 		_findexs $@ | sort | xargs -n1 echo
 	}
 	function _list(){

 		[[ "$DUP" == '0' ]] && FOUND=$(xargs -n1 echo  | awk '!seen[$0]++') || FOUND=$(xargs -n1 echo )
 		[[ "$WRAP" == '1' ]] && xargs -n1 printf "%s$SEP" <<< "$FOUND"
 		# [[ "$WRAP" == '0' ]] && [[ $LINES == 0 ]] && columns <<< $FOUND
 		[[ "$WRAP" == '0' ]] && xargs -n1 echo <<< "$FOUND" 
	}

	case $1 in
		--help*)
				echo "$HELP" && exit
		;;
		--sep*)
			shift 1 && export SEP=$1 &&  _findexe $@
		;;
		--list-duplicates*)

			shift 1 && export DUP=1 &&  _findexe $@
		;;
		-#*)
			shift 1  &&  _findexe $@ 
		;;
		-t*)
			shift 1 &&  export WRAP=1 &&  _findexe $@ 
		;;
		-c*)
			shift 1  &&  _findexe $@ |columns
		;;
		*) 
			_item $@ | _list
		;;
	esac

}
SEP="   "
DUP='0'
COL=1;
LINES='0'
WRAP='0'
_findexe $@
unset -f _findexe
