#!/usr/bin/env bash
function lsexe(){
	HELP="""
use: $lsexe <a|b|c|f|k|A>
    Bash list executables on this system. 
ARGS:
    -a    Aliasses
    -b    Buildins
    -c    Commands
    -f    Functions
    -k    Keywords
    -A    All of the above (also default with no args)
EXAMPLES:
	
	lsexe -A | grep -iE 'top$'       list all runnable things ending in the letters 'top'
	lsexe -a > ~/.bashrc_aliasses    store all kown aliasses in a bashrc file.
"""
	function lscompgen(){
		echo "################# ${1} #################"
		compgen "${2}${3}"
		echo "############################################"
	}
	case $1 in
		a*)
			lscompgen ALIASSES -a
		;;
		b*)
			lscompgen BUILDINS -b
		;;
		c*)
			lscompgen COMMANDS -c
		;;
		f*)
			lscompgen FUNCTIONS -A function
		;;
		k*)
			lscompgen KEYWORDS -k
		;;
		*|A*)
			lsexe a
			lsexe b
			lsexe c
			lsexe f
			lsexe k
		;;
	esac
}
lsexe $@
unset -f lsexe
