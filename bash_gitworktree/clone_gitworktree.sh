#!/usr/bin/env bash

git clone --bare $1 $2 #1=url 2=local folder name for repo
cd $2
git worktree add main
cd main
ls

