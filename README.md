# auto-release-milestone
Auto create release notes when a milestone is reached

# Expected Behavior
1. An event occurs
2. Check that the event was a `milestone`
3. Make sure that the `milestone` even is `closed`
4. Get the name of the `milestone`
5. Feed the `milestone` name and a `repo-token` to the `GitReleaseManager` and create a `release-url`

- `GitReleaseManager` is a `.NET Core` based application and needs that on the host machine in which the action is run
    * `Docker` is a perfect fit for this
    * `Docker` provides a container in which all dependencies required for running any action can be installed, in isolation from the rest of the OS or other `Docker` containers
    * We will create a `Docker` container that will have `.NET Core` and `GitReleaseManager` preinstalled

# You will learn
* How to configure a `Docker` container
  - choose a base image
  - attach metadata with labels
  - installing software
  - specify an entrypoint script that will run automatically on startup
* How to parse GitHub Event Payload from JSON
* How to invoke commands from shellscript
  - Basics of shellscripts using BASH
* How to pass parameters and capture the outputs
  - Pass data from a workflow to a container using input parameters
  - Return data from the container to the workflow using output parameters
* Handling errors in shellscripts
* Report errors back to the workflow through the buildlog

# Release 1.0.0
In this release, the action metadata file `action.yml` declares that the action runs using `Docker` instead of `node12`. We define an output variable called `release-url` in the metadata file. `Dockerfile` defines a `.NET Core SDK 3.1` container, adds some helpful metadata labels, copies from host machine to the virtual filesystem of the container, the primary shellscript `entrypoint.sh` we want to execute our `action` in, and sets that file as the entrypoint for the Docker image when it starts up.

The script `entrypoint.sh` instructs GitHub Actions to set the `actions` output variable `release-url` to a dummy value `https://example.com` by `echo`ing the logging command `"::set-output release-url::https://example.com` and extiting the shell with code 0.

# Release 2.0.0

(TODO)
In this release, we would learn how to parse JSON data.

To parse JSON data, use `./jq` tool. This is not part of the standard UNIX installation. So we would have to install it in Dockerfile.