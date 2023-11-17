#!/usr/bin/env bash
# ############################################################################
# # PATH: bash_scripts/                           AUTHOR: Hoefkens.J@gmail.com
# # FILE: install.sh                                          0v7 - 2023.04.26
# ############################################################################
#
function INSTALLERS(){

	function _install() {
		for FILE in "${FILELIST[@]}" ; do
			DST=$( echo "${DSTROOT}/${FILE}")
			SRC=$( echo "${SRCROOT}/${FILE}")
			printf '%s > - || - < %s \n'  "${SRC}" "${DST}"
			cp -vf $SRC $DST
		done;
	}
	function LocalRC() {
		INSTALL_DIR="$1/config/rc/bash/"
		mkdir -pvf $INSTALL_DIR
		SRCROOT=$( realpath "$PWD/bash_LocalRC/src/bash_LocalRC" )
		DSTROOT=$( realpath "$INSTALL_DIR" )
		DIRLIST=($( find "$SRCROOT"  -type d -printf '%P\n' ))
		FILELIST=($( find "$SRCROOT"  -type f,l -printf '%P\n' ))
		_install 
	}
	function sourcedir() {
		cd Bash_SourceDir
	}
	ROOT="/"
	[[ -z "$2" ]] && ROOT=$2
	[[ -z "$1" ]] && action=$1
	INSTALL_DIR="opt/local"
	INSTALL_DIR="${ROOT}${INSTALL_DIR}"
	LocalRC "$INSTALL_DIR" 	
	

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
		1 | Localrc)
			shift 1 && CASE="LocalRC" && ${FUNCNAME[0]} "$@"
		;;
		2 | sourcedir)
			shift 1 && CASE="SourceDir" && ${FUNCNAME[0]} "$@"
		;;
		*)
			_main "$@"
		;;
		esac;