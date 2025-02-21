#!/bin/bash
# CI CD pipeline script to build, deploy and refresh docker containers using jib maven plugin and using Dockerfile build.
# Copyright 2015-2023 Infospica. All rights reserved.
# Use is subject to license terms.
# Last revised 23 Mar 2022
# Mailto: arun.vc@infospica.com

set -e

help="

  usage: cli.sh -e dev|prod|qa|demo|local -c jib-docker|docker|mvn|save|deploy|up|start|stop|restart|run|run-docker|rm|refresh


  mvn - execute maven build for java projects
  -----

  cli.sh -e dev -c mvn

  jib-docker - build docker container using jib for java spring boot projects
  -----

  cli.sh -e dev -c jib-docker

  docker - build docker container using docker build
  -----

  cli.sh -e dev -c docker

  deploy - deploy the docker image to the host system
  ------

  cli.sh -e dev -c deploy -u ${DEV_SSH_USER:-<sshusername>} -h ${DEV_IP:-<sshhostip>} -p ${DEV_SSH_PORT:-<sshport>}

  refresh - stop remove and spin up the container.
  ------

  cli.sh -e dev -c refresh -a ${DB_USER:-<dbusername>} -s ${DB_PASSWORD:-<dbpassword>} -d ${DB:-<dbname>} -n ${DB_HOST_NAME:-<dbhostname>} -o ${DB_PORT:-<dbport>}


  refresh-remote - stop remove and spin up the container with database fields from env variable, use pipeline variable
  -------

  ./cli.sh -e dev -c refresh-remote -u ${DEV_SSH_USER:-<sshusername>} -h ${DEV_IP:-<sshhostip>} -p ${DEV_SSH_PORT:-<sshport>} -a ${DB_USER:-<dbusername>} -s ${DB_PASSWORD:-<dbpassword>} -d ${DB:-<dbname>} -n ${DB_HOST_NAME:-<dbhostname>} -o ${DB_PORT:-<dbport>}

  ./cli.sh -e dev -c refresh -a dbuser -s password -d mydb -n 172.21.0.2 -o 5432

  -e environment dev|prod|qa|demo|local
  -c command
                run - run locally java maven jar command
                run-docker - run locally docker container.

                jib-docker - create docker container using jib maven plugin for java spring boot projects
                docker - create docker container using docker build command
                mvn - maven build
                save  - save the container to tar file
                deploy - deploy the docker image to an external server. ssh details required, with key added in remote server.
                refresh - refresh the docker container, stop an existing container, remove the container and up the container
                refresh-remote - refresh the docker container in remote server. ssh details required, with key added in remote server.

                up - docker container, docker compose up
                start - docker container, docker compose start
                stop - docker container, docker compose stop
                restart - docker container, docker compose restart
                rm - docker container, docker compose rm

  -u ssh user
  -h ssh host
  -p ssh port eg 22

  -a Database user name
  -s Database password
  -d Database name
  -n Database Host name
  -o Database Port eg 5432, 3306

  -w email host
  -x email user
  -y email password
  -z email  eg 25, 587

  -b any base url
  -t any title text to use

  -f web or admin username
  -g web or admin password

  "

if [ "${1}" == "--help" ]; then
  echo "${help}"
  exit 0;
fi



while getopts e:c::u:h:p:a:s:d:n:o:w:x:y:z:b:t:f:g: flag
do
    case "${flag}" in
        e) X_ENV=${OPTARG:-dev};;
        c) MY_RUN=${OPTARG};;

#ssh host for deploy

        u) SSH_USER=${OPTARG};;
        h) SSH_HOST=${OPTARG};;
        p) SSH_PORT=${OPTARG:-22};;

#database connection args

        a) DB_USER=${OPTARG};;
        s) DB_PASSWORD=${OPTARG};;
        d) DB=${OPTARG};;
        n) DB_HOST_NAME=${OPTARG};;
        o) _DB_PORT=${OPTARG};;

#email smtp connection details

        w) EMAIL_HOST=${OPTARG};;
        x) EMAIL_USER=${OPTARG};;
        y) EMAIL_PASSWORD=${OPTARG};;
        z) EMAIL_PORT=${OPTARG:-25};;

        b) BASE_URL=${OPTARG};;
        t) TITLE=${OPTARG};;

        f) WEB_ADMIN_USER=${OPTARG};;
        g) WEB_ADMIN_PASSWORD=${OPTARG};;

    esac
done






#CUSTOMER, PROJECT, VERSION can be defined in the project source in ./cli-env.sh
if [ ! -f ./cli-env.sh ]; then
#if cli-env.sh not found then look from cloud-cli 
export CUSTOMER=${CUSTOMER:-${CC_CUSTOMER}}
export PROJECT=${PROJECT:-${CC_PROJECT}}
export VERSION=${VERSION:-${CC_APP_VERSION}}
else
source ./cli-env.sh
fi

export CUSTOMER=${CUSTOMER:-"customer"}
export PROJECT=${PROJECT:-"project"}
export VERSION=${VERSION:-"1.0"}

## Build environment and run commands
export BUILD_ENV=${X_ENV}

ENV_PREFIX=""
if [ ! -z "$BUILD_ENV" ] || [ "$BUILD_ENV" == "" ]; then
ENV_PREFIX="-${BUILD_ENV}"
fi

export APP_NAME=${CUSTOMER}-${PROJECT}${ENV_PREFIX}
# export CONTAINER_NAME=${APP_NAME}${ENV_PREFIX}
export APP_IMAGE=${CUSTOMER}/${PROJECT}${ENV_PREFIX}:${VERSION}
export APP_VOLUME=/volumes/${APP_NAME}

if [ ! -z "$DOCKER_COMPOSE_FILE" ] || [ "$DOCKER_COMPOSE_FILE" == "" ]; then
export DOCKER_COMPOSE_FILE=docker-compose${ENV_PREFIX}.yml
fi

if [ -z "$DB_HOST_NAME" ]; then
DB_HOST_NAME="${APP_NAME}-${DB_VENDOR}"
fi

if [ -z "$_DB_PORT" ]; then
_DB_PORT="${DB_PORT}"
fi

export DB_USER=${DB_USER}
export DB_PASSWORD=${DB_PASSWORD}
export DB_HOST_NAME=${DB_HOST_NAME}
export DB_PORT=${_DB_PORT}
export DB=${DB}

export EMAIL_USER=${EMAIL_USER}
export EMAIL_PASSWORD=${EMAIL_PASSWORD}
export EMAIL_HOST=${EMAIL_HOST}
export EMAIL_PORT=${EMAIL_PORT}

export BASE_URL=${BASE_URL}
export TITLE=${TITLE}

export WEB_ADMIN_USER=${WEB_ADMIN_USER}
export WEB_ADMIN_PASSWORD=${WEB_ADMIN_PASSWORD}


echo "JAVA_OPTS=${JAVA_OPTS} "
echo "${BUILD_ENV} environment"

if [ "$MY_RUN" == "refresh" ]; then
docker compose -f ${DOCKER_COMPOSE_FILE} stop
docker compose -f ${DOCKER_COMPOSE_FILE} rm --force
docker compose -f ${DOCKER_COMPOSE_FILE} up --detach
sleep 3
docker compose -f ${DOCKER_COMPOSE_FILE} logs
elif [ "$MY_RUN" == "up" ] || [ "$MY_RUN" == "start" ] || [ "$MY_RUN" == "stop" ] || [ "$MY_RUN" == "restart" ]; then
docker compose -f ${DOCKER_COMPOSE_FILE} "$MY_RUN"
elif [ "$MY_RUN" == "rm" ]; then
docker compose -f ${DOCKER_COMPOSE_FILE} "$MY_RUN" --force
elif [ "$MY_RUN" == "jib-docker" ]; then
mvn clean package jib:dockerBuild
elif [ "$MY_RUN" == "mvn" ]; then
mvn clean package
elif [ "$MY_RUN" == "docker" ]; then
docker build -t ${APP_IMAGE} --build-arg BUILD_ENV=${BUILD_ENV} --build-arg APP_VERSION=${VERSION} .
elif [ "$MY_RUN" == "save" ]; then
docker save -o target/${APP_NAME}.tar ${APP_IMAGE}

elif [ "$MY_RUN" == "deploy" ]; then

scp -P $SSH_PORT -o StrictHostKeyChecking=no ~/server-install.sh "$SSH_USER@$SSH_HOST:~/"
ssh -p $SSH_PORT -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST "cd ~/;./server-install.sh"
docker save ${APP_IMAGE} | bzip2 | ssh -p $SSH_PORT -o StrictHostKeyChecking=no ${SSH_USER}@${SSH_HOST} docker load

elif [ "$MY_RUN" == "refresh-remote" ]; then
DEPLOY=$APP_VOLUME/deploy
CERTS=$APP_VOLUME/certs
TIME=$((`date '+%s%N'`/1000))
ssh -p $SSH_PORT -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST "sudo mkdir -p $DEPLOY;sudo chown ${SSH_USER} ${DEPLOY};sudo chmod 775 ${DEPLOY};cd $DEPLOY;if [ -f ${DOCKER_COMPOSE_FILE} ]; then sudo mv ${DOCKER_COMPOSE_FILE} /tmp/${DOCKER_COMPOSE_FILE}.$TIME; fi;if [ ! -d ${CERTS} ]; then sudo mkdir -p ${CERTS};sudo chown ${SSH_USER} ${CERTS}; sudo chmod 775 ${CERTS}; sudo openssl genrsa -out ${CERTS}/keypair.pem 2048;sudo openssl rsa -in ${CERTS}/keypair.pem -pubout -out ${CERTS}/public.pem;sudo openssl pkcs8 -topk8 -inform PEM -outform PEM -nocrypt -in ${CERTS}/keypair.pem -out ${CERTS}/private.pem;fi"
scp -P $SSH_PORT -o StrictHostKeyChecking=no ${DOCKER_COMPOSE_FILE} cli.sh cli-env.sh "$SSH_USER@$SSH_HOST:$DEPLOY"
ssh -p $SSH_PORT -o StrictHostKeyChecking=no $SSH_USER@$SSH_HOST "cd $DEPLOY;./cli.sh -e \"${BUILD_ENV}\" -c refresh -a \"${DB_USER}\" -s \"${DB_PASSWORD}\" -d \"${DB}\" -n \"${DB_HOST_NAME}\" -o \"${DB_PORT}\" -x \"${EMAIL_USER}\" -y \"${EMAIL_PASSWORD}\" -w \"${EMAIL_HOST}\" -z \"${EMAIL_PORT}\" -b \"${BASE_URL}\" -t \"${TITLE}\" -f \"${WEB_ADMIN_USER}\" -g \"${WEB_ADMIN_PASSWORD}\""

elif [ "$MY_RUN" == "run" ]; then
mvn clean install;java -jar -Dspring.profiles.active=${BUILD_ENV} target/${PROJECT}-${VERSION}.jar
elif [ "$MY_RUN" == "run-docker" ]; then
docker rm "${APP_NAME}"
docker run --name "${APP_NAME}" -it "${APP_IMAGE}"
else
  echo "Unknow command, -c = $MY_RUN \nTry cli.sh --help"
fi


if [ $? != 0 ]; then
  echo "Some thing went wrong\n -c = $MY_RUN \nTry cli.sh --help"
fi
