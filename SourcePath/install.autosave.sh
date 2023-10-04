#!/usr/bin/env bash
# ############################################################################
# # PATH: bash_scripts/Bash_SourceDir_installer  AUTHOR: Hoefkens.J@gmail.com
# # FILE: install.sh                                   0v7 - 2023.04.26
# ############################################################################
#

latest=$(ls "$PWD/bash_sourcedir-"*|sort -n |tail -n 1 )
ln -rsvf "$latest" "$PWD/bash_sourcedir.sh"
ln -svf "$PWD/bash_sourcedir.sh" "/etc/profile.d/bash_sourcedir.sh"
source "/etc/profile.d/bash_sourcedir.sh"
echo "Symlink installed in : /etc/profile.d/" 
bash_sourcedir
unset latest
