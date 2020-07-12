# auto-release-milestone
Auto create release notes when a milestone is reached

# Expected Behavior
1. An event occurs
2. Check that the event was a `milestone`
3. Make sure that the `milestone` even is `closed`
4. Get the name of the `milestone`
5. Feed the `milestone` name and a `repo-token` to the `GitReleaseManager` and create a `release-url`

- `GitReleaseManager` uses `.NET Core` and needs that on the host machine in which the action is run
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
