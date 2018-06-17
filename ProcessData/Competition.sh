#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "wrong number of arguments"
	exit 1
fi

if [[ ! -d $1 ]]; then
	echo "$1 is not a directory"
	exit 2
fi

DIR="$(dirname "$1")/$(basename "$1")/"

function participants {
	find "$1" -type f -regex ".*[0-9A-Z]+" -printf "%f\n" 
}

function outliers {
	find $1 -type f -regex ".*[A-Z0-9]*" -exec awk '{print $9}' {} \; | sort | uniq | tail -n+2 > allnames	
	while read player; do
		sed -i "/^$player$/d" allnames
	done < <( find $1 -type f -printf "%f\n") 
	cat allnames 
	rm allnames 	
}

function unique {
	find $1 -type f -printf "%f\n" >names	
	for i in $(find $1 -type f -printf "%f\n"); do
		awk '{print $9}' "$1$i" | sort | uniq | tail -n+2 >>names
	done	
	 
	cat names | sort | uniq -c | awk -F' ' '$1<=3 {print $2}' 
	rm names
}

function cross_check {
	while read log_part; do
		file="$1$log_part"
		while read i; do
			DATE="$(echo -n $i | tr -s ' ' | cut -d' ' -f4)"
			HOUR="$(echo $i | tr -s ' ' | cut -d' ' -f5)"
			RECEIVER="$(echo $i | tr -s ' ' | cut -d' ' -f9 | cut -d'-' -f3)"
			if [[ $(find $1 -type f -printf "%f\n" | egrep -c "^$RECEIVER$") -eq 0 ]]; then
				awk -v var1=$RECEIVER -v var2=$DATE -v var3=$HOUR '$9==var1 && $4==var2 && $5==var3 {print}' $file 
		 	elif [[ $(awk -v var=$log_part -v var2=$DATE -v var3=$HOUR '$9==var && $4==var2 && $5==var3 {print}' $1$RECEIVER | wc -l) -eq 0 ]]; then
				 awk -v var1=$RECEIVER -v var2=$DATE -v var3=$HOUR '$9==var1 && $4==var2 && $5==var3 {print}' $file 
			fi	
		done < <(cat $file | egrep "^QSO:")	
	done < <(find $1 -type f -printf "%f\n" | sort)
}


function bonus {
	while read log_part; do
		file="$1$log_part"
		while read i; do
			DATE="$(echo -n $i | tr -s ' ' | cut -d' ' -f4)"
			HOUR="$(echo $i | tr -s ' ' | cut -d' ' -f5)"
			RECEIVER="$(echo $i | tr -s ' ' | cut -d' ' -f9 | cut -d'-' -f3)"
			BUFFER=$(( (1$(echo $HOUR | head -c 2) - 100) * 60 + (1$(echo -n $HOUR | tail -c 2) - 100) + 3 ))
			new_hour=$(( $BUFFER / 60 ))
			[[ $new_hour -lt 10 ]] && new_hour="0$new_hour"
			new_min=$(( $BUFFER % 60 ))
			[[ $new_min -lt 10 ]] && new_min="0$new_min"
			HIGHER="$new_hour$new_min"
			BUFFER=$(( (1$(echo $HOUR | head -c 2) - 100) * 60 + (1$(echo -n $HOUR | tail -c 2) - 100) - 3 ))
			new_hour=$(( $BUFFER / 60 ))
			[[ $new_hour -lt 10 ]] && new_hour="0$new_hour"
			new_min=$(( $BUFFER % 60 ))
			[[ $new_min -lt 10 ]] && new_min="0$new_min"
			LOWER="$new_hour$new_min"
		 	if [[ $(find $1 -type f -printf "%f\n" | egrep -c "^$RECEIVER$") -eq 0 ]]; then
				awk -v var1=$RECEIVER -v var2=$DATE -v var3=$HOUR '$9==var1 && $4==var2 && $5==var3 {print}' $file 
		 	elif [[ $(awk -v var=$log_part -v var2=$DATE -v var3=$LOWER -v var4=$HIGHER '$9==var && $4==var2 && $5>=var3 && $5<=var4 {print}' $1$RECEIVER | wc -l) -eq 0 ]]; then
				 awk -v var1=$RECEIVER -v var2=$DATE -v var3=$HOUR '$9==var1 && $4==var2 && $5==var3 {print}' $file 
			fi	
		done < <(cat $file | egrep "^QSO:")	
	done < <(find $1 -type f -printf "%f\n" | sort)
}

case "$2" in 
	"participants" )
		participants "$DIR"
		;;
	"outliers" )
		outliers "$DIR"
		;;
	"unique" )
		unique "$DIR"
		;;
	"cross_check" )
		cross_check "$DIR"
		;;
	"bonus" )
		bonus "$DIR"
		;;
	* )
		echo "No such function exists"
		exit 3
		;;
esac


