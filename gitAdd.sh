#!/bin/bash

RED="\033[0;31m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"
NC="\033[0m"
file=()

getUnstagedFiles () {
        local lineNumber=$(git status | grep -n "Changes not staged" | cut -d ":" -f1)
        if [[ $lineNumber ]]
        then    
                file=($(git status | tail +$lineNumber | grep "modified: " $file | cut -d " " -f4))
        fi
}

printUnstagedFiles () {
        echo "Modified files: "
        for j in "${!file[@]}"
        do      
                echo -e "${CYAN}[$j]${NC} ${RED}${file[j]}${NC}"
        done
}

deleteElement () {
        unset file[$1]
        file=( "${file[@]}" )
}

getUnstagedFiles

if [[ ${#file[@]} -eq 0 ]]
then
        echo "No files to add"
else
        printUnstagedFiles
        echo "Choose a file to add or press 'Q' to quit: "
        read index
        while [[ $index != "Q" && $index != "q" ]]
        do
                if [[ $index -ge ${#file[@]} || $index < 0 ]]
                then
                        maxLength="$((${#file[@]} - 1))"
                        echo "Input must be an integer between 0 and $maxLength"
                elif ! [[ $index =~ ^[0-9]+$ ]]
                then
                        echo "Input must be an integer"
                else
                        git add "${file[index]}"
                        echo -e "File ${PURPLE}${file[index]}${NC} has been added.\n"
                        deleteElement "$index"
                        if [[ ${#file[@]} -eq 0 ]]
                        then
                                echo "All files have been added"
                                break
                        fi
                        printUnstagedFiles
                        echo "Choose a file to add or press 'Q' to quit: "
                fi
                read index
        done
fi
echo "Goodbye, my dude"
