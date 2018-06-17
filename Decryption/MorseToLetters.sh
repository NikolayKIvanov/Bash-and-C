#!/bin/bash

touch morse1
cat morse | tr \. 1 | tr - 2 > morse1
touch secret_message1
cat secret_message | tr \. 1 | tr - 2 > secret_message1 
for item in $(cat secret_message1); do
	IFS=$'\n'	
	for letter in $(cat morse1) ; do
  		if [[ $item = $(echo $letter | cut -d' ' -f2) ]] ; then
	        printf $( echo $letter | cut -d' ' -f1 | tr A-Z a-z) >> encrypted	
		fi
	done
done

printf "\n" >> encrypted
rm morse1 secret_message1 
