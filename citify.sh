#!/bin/bash

# for each metadata file, pre-populate initial metadata based on filename convention
# metadata is prepended to any existing file content

app=${1}
INIT=.init.md

find ./ -type f -iname \*.md -print0 | sort -z | while read -d $'\0' file; do

    # if this file already has front matter defined, skip over file to be safe
    # check first line for front matter start string: "---"
    [ $(sed -n '1{/^\-\-\-/p};q' "${file}") ] && { echo "  - ${file} already has metadata defined, skipping."; continue; }

    if [[ -f "$INIT" ]]; then

        # overwrite without confirmation, which should be safe now...
        \cp ${INIT} ${file}

    else 

        filename="${file##*/}"
        basename="${filename%.*}"
       
        citetext="$basename"
        date=`date -d "${citetext:0:10}" +'%d %b %Y' 2> /dev/null` 
        datevalidity=$? # get date command exit status
        # check that we have a valid ISO date
        if [ "${datevalidity}" -eq 0 ]; then
            citetext="${date}, ${citetext:10}"
        fi
       
        # replace dashes with spaces, title case, and append any command line argument
        citetext="${citetext//-/ }"
        # citetext=`echo "${citetext}" | sed 's/[^ ]\+/\L\u&/g'`
        if [ -n "${app}" ]; then
            citetext="${citetext} ${app}"  
        fi
        
        # prepend formatted front matter string to file
        mdcontent="---\ncitation: \"${citetext}.\"\n---\n\n"
        mdcontent+=`cat "${file}"`
        echo -e $mdcontent > $file

    fi
done

mv .init.md .init.bac
