# Documentation for Common Shell Script Functions

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
build-acr "${VERSION}" "main" "web-api-project-name" "" "Dockerfile.prod" "--no-cache --build-arg SOURCE_BRANCH=master --build-arg NPM_TOKEN=${CC_NPM_TOKEN}"
```


You have already defined git url in your config file

```
# Set environment variables to change your url

## Azure
#export CC_GIT_URL="https://myname@dev.azure.com"

## Github
#export CC_GIT_URL="https://github.com/myorg"

```
---
