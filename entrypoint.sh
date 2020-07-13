#!/bin/bash

#The first line starting with pound character and exclamation is called Shebang
    #This tells the interpreter to execute the script under UNIX operating systems
    #The Shebang #!/bin/bash

#BASH is very lose with syntax. 
    #Use set -u to instruct BASH to issue warnings if
    #we use a variable without declaring it first    
set -u

#read repo-token using the parameter substitution $1 ===${1} as repo-token is the
    #first parameter according to actions metadata file
repo_token=$1

#If event type is not 'milestone', exit.
    #The full name of the JSON file with all info about action is $GITHUB_EVENT_PATH
        #We could use jq to read the event name from this JSON.
    #However, we can also read a convenient variable $GITHUB_EVENT_NAME to get the event name.
#For curiousity's sake, I want to see the entire JSON
#echo "::debug::$(jq . ${GITHUB_EVENT_PATH})"

if [ "${GITHUB_EVENT_NAME}" != "milestone" ]; then
    echo "::debug::The event name was ${GITHUB_EVENT_NAME}"
        #The echo logging command  executes only when debug logging is enabled
            #Otherwise, script exits with 0
    exit 0
fi

#Now that we know the event name is milestone, 
    #we want to make sure that the action was 'closed' as opposed to
        #created
        #updated
        #edited
        #deleted
        #reopened
    #To do that, we have to reach the "action" field in the JSON $GITHUB_EVENT_PATH
        #jq documentation https://stedolan.github.io/jq/manual/
        #Reading a field in JSON using jq goes like this. 
            #We know that "action" is a top level field.
            #jq .<field> <JSON Object>
                #prints the <field> value in JSON format (with quotes), and prints newline
                #The . is the filter operator
            #jq --raw-output .<field> <JSON Object>
                #prints <field> value without quotes, and prints a newline
            #$(jq --raw-output .<field> <JSON Object>)
                #the $(command) is 'command substitution'.
                    #command is executed, output is captured and substituted into the commandline
                        #that contains $(command).
                #FYI ${parameter} is 'parameter substitution'
                    #The value of parameter is substituted.
                        #The braces are required when parameter is a positional parameter 
                            #with more than one digit, or when parameter is followed by a 
                            #character which #is not to be interpreted as part of its name.
                        #Otherwise braces are not needed. 
                            #E.g. $GITHUB_EVENT_PATH === ${GITHUB_EVENT_PATH}
                            #E.g. $event_type === ${event_type}
                #see more: https://superuser.com/questions/935374/difference-between-and-in-shell-script

#Read the 'action' field, and write an if [];then ... fi statement 
    #and print a debug message if the action is not "closed", and then exit immediately
    #no space between var_name=val_value
event_type=$(jq --raw-output ."action" $GITHUB_EVENT_PATH)
if [ event_type != "closed" ]; then
    echo "::debug::The event type is '$event_type'"
fi

#At this point, the event name milestone is confirmed, and we know that the action type was "created"
    #So read the milestone name into a variable.
milestone_name=$(jq --raw-output ."milestone"."title" $GITHUB_EVENT_PATH)

#Internal Field Separator (IFS) can separate out the contents of a string with a particular separator.
    #The bash man page says (https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html)
        #The shell treats each character of $IFS as a delimiter, and splits the results of the other expansions 
            #into words using these characters as field terminators. If IFS is unset, or its value is exactly 
            #<space><tab><newline>, the default, then sequences of <space>, <tab>, and <newline> at the beginning 
            #and end of the results of the previous expansions are ignored, and any sequence of IFS characters not 
            #at the beginning or end serves to delimit words. If IFS has a value other than the default, then 
            #sequences of the whitespace characters space, tab, and newline are ignored at the beginning and end 
            #of the word, as long as the whitespace character is in the value of IFS (an IFS whitespace character). 
            #Any character in IFS that is not IFS whitespace, along with any adjacent IFS whitespace characters, 
            #delimits a field. A sequence of IFS whitespace characters is also treated as a delimiter. 
            #If the value of IFS is null, no word splitting occurs.
    #E.g. repository names in GitHub are like pals-hub/auto-release-milestone where pals-hub is the
        #owner and auto-release-milestone is the repository name.
#We use IFS with separator '/' to split the $GITHUB_REPOSITORY into owner and repo names and use
    #these later with gitreleasemanager
#The <<< is called the Here-string redirection operator. This is used to redirect the read command  
    #to read from a string instead of the typical stdin and assign values into owner and repository variables
#The env variable $GITHUB_REPOSITORY is a string of the form "owner/repository"
IFS='/' read owner repository <<< '${GITHUB_REPOSITORY}'

release_url=$(dotnet gitreleasemanager create \
--milestone $milestone_name \
--targetcommitish $GITHUB_SHA \
--token $repo_token \
--owner $owner \
--repository $repository)

#There are many moving parts here. Many calls are internally being made over the network using the GitHub REST API.
    #Authentication requests are being made. Networks can fail, authentication can be false etc. Eventually, the 
    #code is bound to see a scenario where an error occurs. Handle catch all errors here.
#The symbol for error code returned by the last instruction is '$?'. Any non zero value means error.
    #If last instruction, that is creation of release_url failed when using gitreleasemanager, 
    #issue a logging command error and exit with code 1.
if [ $? -ne 0 ]; then
    echo "::error::Failed to create milestone url"
    exit 1
fi

#instruct the workflow by echoing a logging command that starts with ::command name=output-parameter-name::value
    #we use echo because each logging command must end in a newline character, which echo emits by default
echo "::set-output name=release-url::$release_url"

#tell workflow that the action was successful by setting exit code to 0

exit 0

#mark this file as executable by adding a +x bit to the file by running the following before submitting this script to GitHub
    #Linux or Mac
        #chmod +x entrypoint.sh
    #Windows
        #git add --chmod=+x -- entrypoint.sh
        #git commit
        #git push origin master