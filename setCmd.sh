#!/bin/bash

# Author: PresentJay (정현재, presentj94@ust.ac.kr)

OS_name=$(uname -s)
case ${OS_name} in
    "Darwin"* | "Linux"*) EXT="sh" ;;
    "MINGW32"* | "MINGW64"* | "CYGWIN" ) EXT="bat" ;;
    *) kill "this OS(${OS_name}) is not supported yet." ;;
esac

for script in $(ls scripts/*); do
    OBJ="${script%.*}.$EXT"
    mv -v $script $OBJ
    chmod -x $OBJ
    chmod 777 $OBJ
done
