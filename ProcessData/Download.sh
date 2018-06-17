#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "incorrect number of arguments"
	exit 1
fi

if [[ ! -d $1 ]]; then
	echo "$1 is not a directory"
	exit 2
fi

(cd "$1"; wget -nd -r "$2"
rm $(find . -type f -printf "%f\n" | egrep -v "^[0-9A-Z]+$")
rm $(basename "$2"))

