#!/bin/bash

#prompt user
echo -e "Compiling .l and .y files"

#exec cmd.
$(echo make all)

echo -e "Type the directory in which test programms are stored [default: unit_testing]"
read inp

tests=$(ls "$inp")
color='\033[0;31m'


if (( ${#tests[@]} == 0 )); then
    echo "No subdirectories found" >&2
else

	for i in ${tests[@]}; do

		echo  "		$(tput setaf 2 )	Testing file: ${i} $(tput setaf 7)"
		./ms_compiler < ./$inp/$i
		
	done
fi
