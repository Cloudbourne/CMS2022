#!/bin/bash
source ../init.sh

set -e

echo "---------------------------------"
echo "IMAGE     :" ${IMAGE}
echo "FILE      :" ${IMAGE_FILE}
echo "FOLDER    :" ${IMAGE_FOLDER}
echo "TIMESTAMP :" $(echo $IMAGE_FILE | awk -F'.' '{ print $(NF-1); }')
echo "---------------------------------"

mkdir -vp ${IMAGE_FOLDER}

echo "verifying..."
docker images ${IMAGE}

echo "saving image..."
time docker save --output ${IMAGE_FILE} ${IMAGE}

echo "saved image as" ${IMAGE_FILE} "!" 
ls -lh ${IMAGE_FILE}

echo "please note the TIMESTAMP above."

