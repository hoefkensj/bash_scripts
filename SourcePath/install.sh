#!/usr/bin/env bash
# ############################################################################
# # PATH: bash_scripts/sourcepath_installer  AUTHOR: Hoefkens.J@gmail.com
# # FILE: install.sh                                   0v7 - 2023.04.26
# ############################################################################
#
PKGNAME="SourcePath"
FNCNAME="sourcepath"

function install_me() {
	local INSTALLDIR PKGDIR latest installed
	[[ -z $INSTALLDIR ]] && INSTALLDIR="/opt/local/scripts/bash"
	PKGDIR="${INSTALLDIR}/${PKGNAME}"
	mkdir -vp $PKGDIR
	latest=$(ls -1 "$PWD/src/SourcePath-"*|sort -n |tail -n 1 )
	cp -vf $latest $PKGDIR
	cd $PKGDIR
	installed=$(ls "$PWD/SourcePath-"*|sort -n |tail -n 1 )
	ln -rsvf "$installed" "$PWD/SourcePath.sh"
	ln -svf "$PWD/SourcePath.sh" "/etc/profile.d/SourcePath.sh"
	source "/etc/profile.d/SourcePath.sh"
	$FNCNAME
	echo "Symlink installed in : /etc/profile.d/" 
}
install_me
unset PKGNAME FNCNAME