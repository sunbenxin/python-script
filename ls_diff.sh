#!/bin/bash


git_repo=/home/sunbx/test1/test
ret1=`su - root -c "cd $git_repo>/dev/null && git diff --cached --name-only"`
ret2=`su - root -c "cd $git_repo>/dev/null && git clean -dn"`

echo $ret1
echo $ret2
