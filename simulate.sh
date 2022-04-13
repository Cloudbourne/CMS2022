#!/bin/bash
source ../init.sh
docker exec -it engine bash -c "source /appz/scripts/secrets.bash 2> /dev/null 1> /dev/null && python /appz/scripts/simulate.py $*" 
