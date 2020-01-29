#!/bin/bash

file=''

getUnstagedFiles () {
	local lineNumber=$(git status | grep -n "Changes not staged" | cut -d ":" -f1)
	file=($(git status | tail +$lineNumber | grep "modified: " $file | cut -d " " -f4))
}

printUnstagedFiles () {
	echo "Modified files: "
	echo "${file}"
	for j in "${!file[@]}"
	do
		echo -e "\033[0;36m[$j]\033[0m \033[0;31m${file[j]}\033[0m"
	done
}

deleteElement () {
	unset file[$1]
	file=( "${file[@]}" )
}

getUnstagedFiles
printUnstagedFiles

echo "Choose a file to add or press 'Q' to quit: "
read index
while [[ $index != "Q" && $index != "q" ]]
do
	if [[ $index -ge ${#file[@]} || $index -lt 0 ]]
	then
		maxLength="$((${#file[@]} - 1))"
		echo "Number must be between 0 and $maxLength"
	else
		git add "${file[index]}"
		echo -e "File \033[0;31m${file[j]}\033[0m has been added.\n"
		deleteElement "$index"
		printUnstagedFiles
	fi
	read index
done

echo "Goodbye, my dude"
