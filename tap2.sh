#!/bin/bash
source ../init.sh
docker exec -i engine bash -c "source /appz/scripts/secrets.bash 2> /dev/null 1> /dev/null && python /appz/scripts/tap.py $*"
