#!/usr/bin/env bash
# ############################################################################
# # PATH: bash_scripts/                           AUTHOR: Hoefkens.J@gmail.com
# # FILE: install.sh                                          0v7 - 2023.04.26
# ############################################################################
#

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
[[ -z "$1" ]] && ROOT=$1
INSTALL_DIR="opt/local"
INSTALL_DIR="${ROOT}${INSTALL_DIR}"
LocalRC "$INSTALL_DIR" 	
# ./Bash_SourceDir/install.sh
