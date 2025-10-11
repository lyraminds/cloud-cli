# Documentation for build-docker Shell Script Functions


## `build-acr`

## Description

Builds and pushes a Docker image to Azure Container Registry (ACR) by cloning a source repository and executing a build script. Designed for CI/CD pipelines to automate container image creation.


**Parameters:**

| Parameter       | Required | Default      | Description                                                                 |
|-----------------|----------|--------------|-----------------------------------------------------------------------------|
| `VER`           | Yes      | -            | Version tag for the Docker image (e.g., `1.0.0`)                            |
| `BRANCH`        | Yes      | -            | Git branch to clone (e.g., `main`, `dev`)                                   |
| `PROJECT`       | Yes      | -            | Project name (used for directory and image name)                            |
| `PROJECT_URL`   | Yes      | -            | Git repository path suffix (appended to `CC_GIT_URL`)                       |
| `DOCKER_FILE`   | No       | `Dockerfile` | Path to the Dockerfile (relative to repository root)                       |
| `OPTIONS`       | No       | -            | Additional Docker build options (e.g., `--no-cache --build-arg ENV=prod`)  |


**Usage:** 
```sh
build-acr <VERSION> <BRANCH> <PROJECT> <PROJECT_URL> [DOCKER_FILE] [OPTIONS]
```
build-acr "${VERSION}" "develop-v2" "${PROJECT}" "marvelspace/Trade%20Finance/_git" "Dockerfile" "--build-arg SOURCE_BRANCH=master --build-arg NPM_TOKEN=${CC_NPM_TOKEN}" 


**Example:** 
```sh
build-acr "1.0.0" "main" "my-app" "repo-url"

# Build image with custom Dockerfile and options 
VERSION=1.0.0
#Azure 
build-acr "${VERSION}" "feat/new-ui" "web-ui-project-name" "teamspace/Repo/_git" "Dockerfile.prod" "--no-cache"

#Github 
build-acr "${VERSION}" "main" "web-api-project-name" "myorg" "Dockerfile.prod" "--no-cache --build-arg SOURCE_BRANCH=master --build-arg NPM_TOKEN=${CC_NPM_TOKEN}"
```


You have already defined git url in your config file

```
# Set environment variables to change your url

## Azure
#export CC_GIT_URL="https://myname@dev.azure.com"

## Github
#export CC_GIT_URL="https://github.com/"

```
---


## `run-git`

**Description:** Clones or updates a Git repository.

**Parameters:**

- `$1`: Git URL.
- `$2`: Git project name.
- `$3`: Branch name (optional, defaults to `main`).

**Usage:**

```sh
run-git "http://git.company.com/companyspace" "myproject" "master"
```
----



✅ To build Docker images in parallel:

- Add `&` at the end of each build command.
- Add `wait` at the end of the script to wait for all jobs to complete.
- The number of parallel jobs depends on the number of agents or CPU quota available.

Example:

```
backend() {
local PROJECT=${1}; 
build-acr "${VERSION}" "develop" "${PROJECT}" "myspace/MyProject/_git" "Dockerfile" "--build-arg INDEX_URL=${CC_PYTHON_REPO}"
}

frontend() {
local PROJECT=${1}; 
build-acr "${VERSION}" "develop-v2" "${PROJECT}" "myspace/MyProject/_git" "Dockerfile" "--build-arg SOURCE_BRANCH=master --build-arg NPM_TOKEN=${CC_NPM_TOKEN}" 
}

backend "reports-api" &
backend "app-api" &
frontend "app-ui" &

wait
echo "✅ All builds completed."

```

📝 To log output for each build:

Use `> logs/logfilename.log 2>&1 &` to redirect stdout and stderr to a log file.

Example:

```
backend "reports-api" > logs/reports-api.log 2>&1 &
backend "app-api" > logs/app-api.log 2>&1 &
frontend "app-ui" > logs/app-ui.log 2>&1 &

wait
echo "✅ All builds completed."
```
