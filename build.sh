#!/bin/bash

echo "#define" __TIME_UNIX__         $(date +%s)                                                    >  ./src/timestamp.h
echo "#define" __SVN_COMMIT__ '"'SVN-$(svn info | grep "Last Changed Rev:" | cut -d " " -f 4)'"'    >> ./src/timestamp.h
echo "#define" __GIT_COMMIT__ '"'GIT-$(git log -n1 | grep commit | cut -d " " -f 2)'"'              >> ./src/timestamp.h
make clean
make
