#!/bin/bash

arrBig=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
arrSmall=(a b c d e f g h i j k l m n o p q r s t u v w x y z)
touch temp1 temp
for item in {0..25}; do
	cat encrypted >temp 
	for letter in {0..25}; do
		cat temp | tr ${arrSmall[$letter]} ${arrBig[$((( ($item + $letter) % 26)))]} >temp1
		cat temp1 > temp
	done 
	if [[ $(cat temp | egrep -o -c "FUEHRER") -ge 1 ]]; then
		cat temp | tr A-Z a-z
		printf "\n"	
		break 
	fi
done

rm temp1 temp	
