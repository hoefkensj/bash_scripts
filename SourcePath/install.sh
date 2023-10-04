#!/usr/bin/env bash
# ############################################################################
# # PATH: bash_scripts/sourcepath_installer  AUTHOR: Hoefkens.J@gmail.com
# # FILE: install.sh                                   0v7 - 2023.04.26
# ############################################################################
#
INSTALLDIR=/opt/local/scripts/bash/SourcePath/
mkdir -p $INSTALLDIR
latest=$(ls "$PWD/src/SourcePath-"*|sort -n |tail -n 1 )
cp $latest $INSTALLDIR
cd $INSTALLDIR
installed=$(ls "$PWD/SourcePath-"*|sort -n |tail -n 1 )
ln -rsvf "$installed" "$PWD/SourcePath.sh"
ln -svf "$PWD/SourcePath.sh" "/etc/profile.d/SourcePath.sh"
source "/etc/profile.d/SourcePath.sh"
sourcepath
echo "Symlink installed in : /etc/profile.d/" 
unset latest