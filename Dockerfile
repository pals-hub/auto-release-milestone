#GitHub Documentation: https://docs.github.com/en/actions/creating-actions/dockerfile-support-for-github-actions

#FROM
    #ARG is the only instruction that may precede FROM in the Dockerfile and ARG provides arguments to the FROM instruction
    #FROM: (Required) The first instruction in the Dockerfile must be FROM, which selects a Docker base image. 
    #Docker Doc for FROM: https://docs.docker.com/engine/reference/builder/#from
    #Three supported syntaxes for FROM are
        #FROM [--platform=<platform>] <image> [AS <name>]
        #FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
        #FROM [--platform=<platform>] <image>[@<digest>] [AS <name>]
    #FROM instruction initializes a new build stage and 
        #sets the Base Image for subsequent instructions
    #FROM can appear multiple times within a single Dockerfile to 
        #create multiple images or use one build stage as a
        #dependency for another. Simply make a note of the last 
        #image ID output by the commit before each new FROM instruction. 
    #Each FROM instruction clears any state created by previous instructions.
    #AS <name> (Optional) a name can be given to a new build stage by adding 
        #AS name to the FROM instruction. 
        #The name can be used in subsequent FROM and COPY --from=<name|index> 
        #instructions to refer to the image built in this stage.
    #[:<tag>] or [@<digest>] values are optional. 
        #If you omit either of them, the builder assumes a latest tag by default. 
        #The builder returns an error if it cannot find the tag value.
    #[--platform=<platform>] is an optional flag to specify the platform of the image
        #Use this when FROM references a multi-platform image
        #Examples: linux/amd64, linux/arm64, or windows/amd64
            #By default, the target platform of the build request is used. 
            #Global build arguments can be used in the value of this flag, 
            #for example automatic platform ARGs allow you to force a 
            #stage to native build platform (--platform=$BUILDPLATFORM), and 
            #use it to cross-compile to the target platform inside the stage.

#Base the image on dotnet core SDK to install GitReleaseManager later
    #Image name is mentioned in the documentation for .NET Core SDK 3.1 
        #Docker container at https://hub.docker.com/_/microsoft-dotnet-core-sdk/
        #Image name is mcr.microsoft.com/dotnet/core/sdk:3.1
FROM mcr.microsoft.com/dotnet/core/sdk:3.1

#LABEL:
    #LABEL (Optional): The LABEL instruction adds metadata to an image. 
        #A LABEL is a key-value pair. 
        #To include spaces within a LABEL value, 
        #use quotes and backslashes as you would in command-line parsing.
            #Examples:
                #LABEL "com.example.vendor"="ACME Incorporated"
                #LABEL com.example.label-with-value="foo"
                #LABEL version="1.0"
                #LABEL description="This text illustrates \
                #that label-values can span multiple lines."
        #An image can have more than one label. 
        #You can specify multiple labels on a single line in two ways.
            #LABEL multi.label1="value1" multi.label2="value2" other="value3"
            #LABEL multi.label1="value1" \
            #      multi.label2="value2" \
            #      other="value3"

#Some metadata to make search easier
    #GitHub Specific
LABEL "com.github.actions.name"="Auto Release Manager"
LABEL "com.github.actions.description"="Draft a GitHub Release"

    #Docker specific metadata
LABEL version="0.1.0"
LABEL repository="https://github.com/pals-hub/auto-release-milestone"
LABEL maintainer="Prabhat Pal"

#RUN

#Install jq to parse JSON data.
    #Write RUN instructions as if you are writing it on a terminal
    #Use && to separate out two commands on the same line because 
        #Docker caches the state of the container, called a layer
        #with each RUN statement and we don't want to run the risk of
        #using an older cached version of the package database
    #The flag -y tells to install assuming 'YES' as answer to user prompts
    #After this statement executes, we can assume that the container has jq!
RUN apt-get update && apt-get install -y jq

#Install GitReleaseManager using RUN instruction as shown below.
    #Flag -g stands for global. Ensures we can invoke GtiReleaseManager 
        #from anywhere in the system
RUN dotnet tool install -g GitReleaseManager.Tool

#Installing alone doesn't update the $PATH env variable to indicate where
    #the new GitReleaseManager.Tool is installed. To do that we use the ENV
    #instruction. 'ENV <var_name> <var value>'.
#Set the env var PATH to its current value prepended by /root/.dotnet/tools
ENV PATH /root/.dotnet/tools:$PATH

#Now we can run the GitReleaseManager by calling dotnet-gitreleasemanager
    #in our shell script

#COPY
    #COPY: We must copy the shell script from our host fiesystem, to the
        #virtual filesystem of the Docker container for the GitHub action 
        #to be executed.
    #COPY: Two forms of COPY are
        #COPY [--chown=<user>:<group>] <src>... <dest>
        #COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
            #Must use the second form with double quotation marks in 
                #source and destination if paths contain whitespace
    #The --chown feature is only supported on Dockerfiles used to 
        #build Linux containers, and will not work on Windows containers. 
        #Since user and group ownership concepts do not translate between 
        #Linux and Windows, the use of /etc/passwd and /etc/group for 
        #translating user and group names to IDs restricts this feature 
        #to only be viable for Linux OS-based containers.    
    #Paths of source files and directories will be interpreted as relative 
        #to the source of the context of the build. The <src> path must be 
        #inside the context of the build; you cannot COPY ../something /something, 
        #because the first step of a docker build is to send the context 
        #directory (and subdirectories) to the docker daemon.
    #Multiple <src> resources may be specified.
    #The <dest> can be either absolute or relative path.
        #Relative destination path example:
            #COPY test.txt my/relative/dir/
                #The <dest> my/relative/dir/ does NOT start with a /
                    #indicating that the <dest> is relative to <WORKDIR>
                #The <dest> ends in a / indicating that the 
                    #destination is a directory, and NOT a file.
            #COPY test.txt /my/absolute/dir/
                #This <dest> is an absolute path (as it starts with /) to 
                    #a directory (as it ends with /) on the virtual filesystem 
                    #inside the Docker image 
    #If <src> is a directory, the entire contents of the directory are copied, 
        #including filesystem metadata. The directory itself is not copied, just its contents.
            #If <src> is any other kind of file, it is copied individually along with its metadata. 
                #In this case, if <dest> ends with a trailing slash /, it will be considered a 
                #directory and the contents of <src> will be written at <dest>/base(<src>).
    #If multiple <src> resources are specified, either directly or due to the use of a wildcard, 
        #then <dest> must be a directory, and it must end with a slash /.
    #If <dest> does not end with a trailing slash, it will be considered a regular 
        #file and the contents of <src> will be written at <dest>.
    #If <dest> doesn’t exist, it is created along with all missing directories in its path.

#Path to the schellscript to run as soon as the container starts up
    #script name is entrypoint.sh
    #copy the script file from host file system to the virtual file system of the container
    #specify the path to entrypoint.sh relative to the Dockerfile
    #copy destination is the root of the virtual file system, which in UNIX is /
COPY entrypoint.sh /entrypoint.sh

#ENTRYPOINT: An ENTRYPOINT allows you to configure a container that will run as an executable
    #ENTRYPOINT instruction has two forms:
        #The exec form, which is the preferred form:
            #ENTRYPOINT ["executable", "param1", "param2"]
        #The shell form
            #ENTRYPOINT command param1 param2
    #If you define multiple ENTRYPOINT instructions, only the 
        #last ENTRYPOINT instruction in the Dockerfile will have an effect.

#use the keyword, ENTRYPOINT to specify the command to run on startup
    #specify an array of strings as "executable file", ["<arguments>"]
    #typically, we would not pass arguments from here
    #instead, GitHub actions would automatically pass the required arguments
ENTRYPOINT [ "/entrypoint.sh" ]