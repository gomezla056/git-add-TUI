#!/bin/bash

RED="\033[0;31m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
NC="\033[0m"
file=()
untrackedFiles=()
allFiles=()

getUnstagedFiles () {
	local lineNumber=$(git status | grep -n "Changes not staged" | cut -d ":" -f1)
	if [[ $lineNumber ]]
	then
		file=($(git status | tail +$lineNumber | grep "modified: " $file | cut -d " " -f4))
	fi
}

getUntrackedFiles () {
	local lineNumber=$(git status | grep -n "Untracked files" | cut -d ":" -f1)
	if [[ $lineNumber ]]
	then
		untrackedFiles=($(git status | tail +$lineNumber | grep -E "^\s+\w+" | xargs))
	fi
}

getFiles () {
	getUnstagedFiles
	getUntrackedFiles
}

printUnstagedFiles () {
	echo "Modified files: "
	for j in "${!file[@]}"
	do
		echo -e "${CYAN}[$j]${NC} ${RED}${file[j]}${NC}"
	done
	echo
}

printUntrackedFiles () {
	echo "Untracked files: "
	for j in "${!untrackedFiles[@]}"
	do
		echo -e "${CYAN}[$(($j + ${#file[@]}))]${NC} ${RED}${untrackedFiles[j]}${NC}"
	done
	echo
}

printAllFiles () {
	if [[ ${#file[@]} -gt 0 ]]
	then
		printUnstagedFiles
	fi
	if [[ ${#untrackedFiles[@]} -gt 0 ]]
	then
		printUntrackedFiles
	fi
}

addFile () {
	if [[ $1 -lt ${#file[@]} ]]
	then
		git add "${file[$1]}"
		echo -e "File ${PURPLE}${file[$1]}${NC} has been added.\n"

	else
		git add "${untrackedFiles[$(($1 - ${#file[@]}))]}"
		echo -e "File ${PURPLE}${untrackedFiles[$(($1 - ${#file[@]}))]}${NC} has been added.\n"

	fi
}

deleteFile () {
	if [[ $1 -lt ${#file[@]} ]]
	then
		unset file[$1]
		file=( "${file[@]}" )
	else
		unset untrackedFiles[$(($1 - ${#file[@]}))]
		untrackedFiles=( "${untrackedFiles[@]}" )
	fi
}

getFiles

if [[ ${#file[@]} -eq 0 && ${#untrackedFiles[@]} ]]
then
	echo "No files to add"
else
	printAllFiles
	echo "Choose a file to add or press 'Q' to quit: "
	read index
	while [[ $index != "Q" && $index != "q" ]]
	do
		if [[ $index -ge $((${#file[@]} + ${#untrackedFiles[@]})) || $index < 0 ]]
		then
			maxLength="$((${#file[@]} + ${#untrackedFiles[@]} - 1))"
			echo "Input must be an integer between 0 and $maxLength"
		elif ! [[ $index =~ ^[0-9]+$ ]]
		then
			echo "Input must be an integer"
		else
			addFile "$index"
			deleteFile "$index"
			if [[ ${#file[@]} -eq 0 && ${#untrackedFiles[@]} -eq 0 ]]
			then
				echo "All files have been added"
				break
			fi
			printAllFiles
			echo "Choose a file to add or press 'Q' to quit: "
		fi
		read index
	done
fi
echo "Goodbye, my dude"
