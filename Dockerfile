#Base the image on dotnet core SDK to install GitReleaseManager later
FROM mcr.microsoft.com/dotnet/core/sdk:3.1

#some metadata to make search easier
#GitHub Specific
LABEL "com.github.actions.name"="Auto Release Manager"
LABEL "com.github.actions.description"="Draft a GitHub Release"

#Docker specific metadata
LABEL version="0.1.0"
LABEL repository="https://github.com/pals-hub/auto-release-milestone"
LABEL maintainer="Prabhat Pal"

#Path to the schellscript to run as soon as the container starts up
#script name is entrypoint.sh
#copy the script file from host file system to the virtual file system of the container
#specify the path to entrypoint.sh relative to the Dockerfile
#copy destination is the root of the virtual file system, which in UNIX is /
COPY entrypoint.sh /

#use the keyword, ENTRYPOINT to specify the command to run on startup
#specify an array of strings as args
#first is the executable to run, next are the arguments you want to pass to the executable
ENTRYPOINT [ "/entrypoint.sh" ]