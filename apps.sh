#!/bin/bash
if [ -z "$APPZ_ENV" ]; then
	echo "APPZ_ENV is not set. Please set it and run apps.sh"
	exit 1
fi
dir=${PWD##*/}
if [ "$dir" == "engine-2.0" ]; then
  docker inspect -f '{{.State.Running}}' engine >/dev/null 2>/dev/null
 if [ $? -eq  0 ]; then
   echo "Adding the app and acl to the engine"
   ../tap2.sh --app ecloudcontrol/vault < ../vault-1.2/app."$APPZ_ENV".txt
   ../tap2.sh --acl jcarver/ecloudcontrol/vault/DEV < ../vault-1.2/app.dev.txt
   ../tap2.sh --app ecloudcontrol/appz-logcollectordb < ../mongo-3.2/app."$APPZ_ENV".txt
   ../tap2.sh --acl jcarver/ecloudcontrol/appz-logcollectordb/DEV < ../mongo-3.2/app.dev.txt
   ../tap2.sh --app ecloudcontrol/appz-logcollectorgl < ../graylog-3.0/app."$APPZ_ENV".txt
   ../tap2.sh --acl jcarver/ecloudcontrol/appz-logcollectorgl/DEV < ../graylog-3.0/app.dev.txt
   ../tap2.sh --app ecloudcontrol/appz-logcollectores < ../elasticsearch-5.6/app."$APPZ_ENV".txt
   ../tap2.sh --acl jcarver/ecloudcontrol/appz-logcollectores/DEV < ../elasticsearch-5.6/app.dev.txt

 else
   echo "Engine is not running. Please rerun install.sh after starting Engine."
   exit 1
 fi
else 
   echo "Please switch to  engine-2.0 folder and rerun apps.sh"
fi

