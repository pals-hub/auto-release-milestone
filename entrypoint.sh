#!/bin/bash

#The first line starting with pound character and exclamation is called Shebang
#This tells the interpreter to execute the script under UNIX operating systems

#BASH is very lose with syntax. Use set -u to instruct BASH to issue warnings if we use a variable without declaring it first
set -u

#instruct the workflow by echoing a logging command that starts with ::command name=output-parameter-name::value
#we use echo because each logging command must end in a newline character, which echo emits by default
echo "::set-output name=release-url::http://example.com"

#tell workflow that the action was successful by setting exit code to 0

exit 0

#mark this file as executable by adding a +x bit to the file by running the following before submitting this script to GitHub
#Linux or Mac
#chmod +x entrypoint.sh

#Windows
#git add --chmod=+x -- entrypoint.sh
#git commit
#git push origin master