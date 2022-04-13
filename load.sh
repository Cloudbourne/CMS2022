#!/bin/bash
source ../init.sh

set -e

CONFIRM1=$(echo ${CONTAINER} | tr '[:lower:]' '[:upper:]')

echo "****** This will overwrite local image" ${IMAGE} "******"
echo "please ensure that you save a copy using ../save.sh. "
read -p "enter ${CONFIRM1} to confirm: " CONFIRM2
if [[ "$CONFIRM1" != "$CONFIRM2" ]]; then
	echo "image not loaded. exiting!"
	exit -1
fi		

TS=$(echo $IMAGE_FILE | awk -F'.' '{ print $(NF-1); }')
read -p "enter TIMESTAMP of the image file: " TIMESTAMP
IMAGE_FILE=$(echo ${IMAGE_FILE/$TS/$TIMESTAMP})

echo "---------------------------------"
echo "IMAGE     :" ${IMAGE}
echo "FILE      :" ${IMAGE_FILE}
echo "FOLDER    :" ${IMAGE_FOLDER}
echo "TIMESTAMP :" $(echo $IMAGE_FILE | awk -F'.' '{ print $(NF-1); }')
echo "---------------------------------"

if [ ! -f ${IMAGE_FILE} ]; then
    echo "Image file not found. exiting!"
    exit -1
fi

echo "loading image from "${IMAGE_FILE}"..."
time docker load --input ${IMAGE_FILE}

echo "verifying..."
docker images ${IMAGE}

echo "image loaded successfully!!!" 
