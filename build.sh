#!/usr/bin/env bash

set -e

if [ -z ${1} ]
then
    echo "Missing parameter, Name."
    exit -1
fi

NAME=${1}
MACHINE_NAME="debian-12-kas"

docker build -t ${NAME}/${MACHINE_NAME} .
