#!/bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
#trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
#trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

log_report() {
    echo "Engine is not running. Please rerun install.sh after starting Engine."
}


if [ -z "$APPZ_ENV" ]; then
  echo "APPZ_ENV is not set. Please set it and run install.sh"
  exit 1
fi
if [ -x "$(command -v docker)" ]; then
    echo "docker already installed"

else
    echo "Installing docker..."
  sudo yum update -y
  sudo yum install -y \
       yum-utils \
       device-mapper-persistent-data \
       lvm2
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install docker-ce-18.06.1.ce-3.el7
  if [ $? -eq 0 ]; then
          echo "Docker installed successfully"
          sudo docker version
          sudo usermod -aG docker $(whoami)
  else
          echo "couldn't complete installtion"
      exit 1
  fi
fi
if [ ! -f ~/.appz/init.conf ]; then
     echo "~/.appz/init.conf file not found"
     exit 1
fi
chmod go-rw ~/.appz
chmod go-rw ~/.appz/init.conf
source ~/.appz/init.conf
if [ $? -eq  0 ]; then
        echo "source ~/.appz/init.sh successfully"
else
        echo "failed to source ~/.appz/init.sh"
    exit 1
fi
if [ ! -d ~/.docker ]; then
    mkdir -p ~/.docker
fi
if [ -d ~/.docker ]; then
    sudo chown -R $USER:$USER  ~/.docker
    echo "permission updated for "~/.docker""
fi
if [ -d ~/.kube ]; then
   sudo chown -R $USER:$USER  ~/.kube
   echo "permission updated for "~/.kube""
fi
root_path=$(pwd)
echo "---------"
echo "checking docker credentials to access AppZ registry..."
docker login
if [ $? -eq  0 ]; then
  echo "docker login successfully"
else
     echo "docker login failed"
     exit 1
fi

images=( wordpress-5.4 aws-0.2 installer-3.0 prometheus-2.17 grafana-7.0 ansible-2.9 tomcat9-9.0 jenkins-2.0 helm-2.16 helm-3.1 modcluster-1.3 telemetry_es-0.2 telemetry_fluentbit-0.2 kafkaops-0.2 nodexporter-0.2 zeebe-0.22 k8sinstaller-0.2 rabbitmq-3.7 cassandra-3.11 engine-2.0 ant-1.10 maven-3.5 vault-1.2 mysql-5.7 dashboard-2.0 gitpoller-0.2 mongo-3.2 elasticsearch-5.6 graylog-3.0 httpd-2.0 gitlab-12.9 tomcat8_base-8.0 mariadb_master-10.4 mariadb_slave-10.4 postgres_master-12.2 postgres_slave-12.2 confluent-5.4 kafkacat_consumer-5.1 kafkacat_producer-5.1 telemetry_prom-0.2 springboot_base-0.2 mongo-3.4 elasticsearch-6.8 graylog-3.1 sonarqube_azl-8.2 )
for i in "${images[@]}"
do
        echo ----------------------- pulling $i -----------------------
        cd $i
        bash -c "../pull.sh"
        cd $root_path
done

# pull images from docker.io and push to $COMMON_REGISTRY
image=( confluentinc/cp-operator-service:0.275.1 confluentinc/cp-init-container-operator:5.4.1.0 confluentinc/cp-zookeeper-operator:5.4.1.0 confluentinc/cp-server-operator:5.4.1.0 confluentinc/cp-schema-registry-operator:5.4.1.0 confluentinc/cp-server-connect-operator:5.4.1.0 confluentinc/cp-enterprise-replicator-operator:5.4.1.0 confluentinc/cp-enterprise-control-center-operator:5.4.1.0 confluentinc/cp-ksql-server-operator:5.4.1.0 )
for i in "${image[@]}"
do
       echo "---------------------- pulling  $i  from docker.io -----------------------"
        docker pull docker.io/$i
        docker tag $i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done

# pull images from quay.io and push to $COMMON_REGISTRY

image=( prometheus/node-exporter:v0.17.0 coreos/kube-state-metrics:v1.5.0 prometheus/prometheus:v2.11.1 prometheus/alertmanager:v0.16.0 )

for i in "${image[@]}"
do
       echo "---------------------- pulling  $i from quay.io -----------------------"
        docker pull quay.io/$i
        docker tag quay.io/$i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done
# pull images from docker.io and push to $COMMON_REGISTRY
image=( grafana/grafana:6.0.1 debian:9 )
for i in "${image[@]}"
do
       echo "---------------------- pulling  $i from docker.io -----------------------"
        docker pull $i
        docker tag $i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done
# pull images from k8s.gcr.io  and push to $COMMON_REGISTRY
image=( addon-resizer:1.7 )
for i in "${image[@]}"
do
       echo "---------------------- pulling  $i from k8s.gcr.io -----------------------"
        docker pull k8s.gcr.io/$i
        docker tag  k8s.gcr.io/$i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done

image=( ubuntu:18.04 )
for i in "${image[@]}"
do
       echo "---------------------- pulling  $i  from docker.io -----------------------"
        docker pull docker.io/$i
        docker tag $i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done

image=( alpine:3.6 fluent/fluent-bit:1.3.11 )
for i in "${image[@]}"
do
       echo "---------------------- pulling  $i  from docker.io -----------------------"
        docker pull docker.io/$i
        docker tag $i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done
image=( fluentd_elasticsearch/fluentd:v3.0.1 )
for i in "${image[@]}"
do
       echo "---------------------- pulling  $i from quay.io -----------------------"
        docker pull quay.io/$i
        docker tag quay.io/$i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done

image=( elasticsearch/elasticsearch:7.7.0 kibana/kibana:7.7.0 )
for i in "${image[@]}"
do
       echo "---------------------- pulling  $i from elastic.co -----------------------"
        docker pull docker.elastic.co/$i
        docker tag docker.elastic.co/$i $COMMON_REGISTRY/$i
       echo "---------------------- pushing  $i  to cloudcontrol registry  -----------------------"
        docker push $COMMON_REGISTRY/$i
done

echo ----------------------- building dashboard -----------------------
cd dashboard-2.0
bash -c "../build.sh"
cd $root_path

echo ----------------------- building httpd -----------------------
cd httpd-2.0
bash -c "../build.sh"
cd $root_path

echo ----------------------- building maven -----------------------
cd maven-3.5
bash -c "../build.sh"
cd $root_path

if [ ! -d /home/appz/volumes/common/keys ]; then
        sudo mkdir -p /home/appz/volumes/common/keys
fi
if [ "$USER" = "root" ]; then
  echo "user is root"
 bash -c "cat > /home/appz/volumes/common/keys/engine.yaml" <<  EOF
---
  keys:
     primary_secret: $ENGINE_PRIMARY_SECRET
EOF
else
  echo "user is $USER"
sudo bash -c "cat > /home/appz/volumes/common/keys/engine.yaml" <<  EOF
---
keys:
   primary_secret: $ENGINE_PRIMARY_SECRET
EOF
fi

if [ $? -eq  0 ]; then
        echo "engine.yaml updated in "/home/appz/volumes/common/keys""
else
        echo "failed to update engine.yaml"
    exit 1
fi

if [ "$USER" = "root" ]; then
  echo "user is root"
bash -c "cat > /home/appz/volumes/common/keys/dashboard.yaml" << EOF
primary_secret: $DASHBOARD_PRIMARY_SECRET
db_primary_secret: $DASHBOARD_DB_SECRET
EOF
else
  echo "user is $USER"
sudo bash -c "cat > /home/appz/volumes/common/keys/dashboard.yaml" << EOF
primary_secret: $DASHBOARD_PRIMARY_SECRET
db_primary_secret: $DASHBOARD_DB_SECRET
EOF
fi

if [ $? -eq  0 ]; then
        echo "dashboard.yaml updated in "/home/appz/volumes/common/keys""
else
        echo "failed to update dashboard.yaml"
    exit 1
fi
if [ ! -d /home/appz/volumes/engine-2.0/home/ ]; then
     sudo mkdir -p /home/appz/volumes/engine-2.0/home
fi

if [ "$USER" = "root" ]; then
  echo "user is root"
bash -c "cat > /home/appz/volumes/engine-2.0/home/engine.yaml" <<EOF
appz :
  baseurl : $BASE_URL
  alerts:
     email: $ALERT_EMAIL
build :
  cache : /home/appz/volumes/engine-2.0/cache
  token :
    alpha : $GIT_TOKEN
    aint: $AINT_TOKEN
  output:
     default:
        error:
           - exclude : "WARNING|0 Error.s.|errorprone|failureaccess|maven.error.diagnostics|errorresponse" # case sensitive !!!
           - match : "BUILD FAILED|BUILD FAILURE"
             lines : 1
             summary : true
           - match : "error|fatal|failure"
             lines : 0
        warn:
           - exclude: "nowarn|0 Warning.s."
           - match : "warn|deprecat"
             lines : 0
image :
  registry :
    host : $REGISTRY_HOST
deploy:
  template:
    sonarqube8: /appz/docker/engine-2.0/yaml/sonarqube8.yaml
vault:
   alpha-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
   alpha-integration-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
   mystatestreet-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
   ea-sharedservices-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
smtp:
  from: $FROM_EMAIL
  host: $SMTP_HOST
  port: $SMTP_PORT
  authenticate : $SMTP_AUTH
log:
  collector :
    host : appz-logcollectorgl-2-9.alpha-dev
monitor :
  influx :
    url : $MONITOR_INFLUX_ENDPOINT/query?db=k8s
collect:
  endpoint:
    host: $COLLECT_HOST
    port: $COLLECT_PORT    
EOF
else
  echo "user is $USER"
if [ "$APPZ_ENV" = "ntnx" ]; then
sudo bash -c "cat > /home/appz/volumes/engine-2.0/home/engine.yaml" <<EOF

appz :
  baseurl : $BASE_URL
  alerts:
     email: $ALERT_EMAIL
build :
  cache : /home/appz/volumes/engine-2.0/cache
  token :
    alpha : $GIT_TOKEN
  output:
     default:
        error:
           - exclude : "WARNING|0 Error.s." # case sensitive !!!
           - match : "BUILD FAILED|BUILD FAILURE"
             lines : 1
             summary : true
           - match : "error|fatal|failure"
             lines : 0
        warn:
           - exclude: "nowarn|0 Warning.s."
           - match : "warn|deprecat"
             lines : 0
image :
  registry :
    host : $REGISTRY_HOST
deploy:
  template:
    sonarqube8: /appz/docker/engine-2.0/yaml/sonarqube8.yaml
vault:
   alpha-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
   ea-sharedservices-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
smtp:
  from: $FROM_EMAIL
  host: $SMTP_HOST
  port: $SMTP_PORT
  authenticate : $SMTP_AUTH
log:
  collector :
    host : appz-logcollectorgl-3-1.alpha-dev
monitor :
  influx :
    url : $MONITOR_INFLUX_ENDPOINT/query?db=k8s
EOF

else
sudo bash -c "cat > /home/appz/volumes/engine-2.0/home/engine.yaml" <<EOF

appz :
  baseurl : $BASE_URL
  alerts:
     email: $ALERT_EMAIL
build :
  cache : /home/appz/volumes/engine-2.0/cache
  token :
    alpha : $GIT_TOKEN
  output:
     default:
        error:
           - exclude : "WARNING|0 Error.s." # case sensitive !!!
           - match : "BUILD FAILED|BUILD FAILURE"
             lines : 1
             summary : true
           - match : "error|fatal|failure"
             lines : 0
        warn:
           - exclude: "nowarn|0 Warning.s."
           - match : "warn|deprecat"
             lines : 0
image :
  registry :
    host : $REGISTRY_HOST
deploy:
  template:
    sonarqube8: /appz/docker/engine-2.0/yaml/sonarqube8.yaml
vault:
   alpha-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
   ea-sharedservices-dev :
      svc : vault-0-4
      addr : vault-0-4:8200
smtp:
  from: $FROM_EMAIL
  host: $SMTP_HOST
  port: $SMTP_PORT
  authenticate : $SMTP_AUTH
log:
  collector :
    host : appz-logcollectorgl-2-9.alpha-dev
monitor :
  influx :
    url : $MONITOR_INFLUX_ENDPOINT/query?db=k8s
EOF
fi
fi
if [ $? -eq  0 ]; then
        echo "engine.yaml  updated in "/home/appz/volumes/engine-2.0/home/engine.yaml""
else
        echo "failed to update engine.yaml"
    exit 1
fi
if [ -f ~/.kube/config ]; then
   echo "updating kubectl.conf"
   if [ "$APPZ_ENV" = "alpha" ]; then
	 sed -e "/contexts:/a\- context:\n    cluster: cc-demo-1\n    user: cc-demo-1\n    namespace: alpha-dev\n  name: alpha/DEV" <  ~/.kube/config > engine-2.0/kubectl.conf
	 sed -i "/contexts:/a\- context:\n    cluster: cc-demo-1\n    user: cc-demo-1\n    namespace: alpha-integration-dev\n  name: alpha-integration/DEV" engine-2.0/kubectl.conf
	 sed -i "/contexts:/a\- context:\n    cluster: cc-demo-1\n    user: cc-demo-1\n    namespace: kube-system\n  name: kube/SYSTEM" engine-2.0/kubectl.conf
	 sed -i "/contexts:/a\- context:\n    cluster: cc-demo-1\n    user: cc-demo-1\n    namespace: mystatestreet-dev\n  name: mystatestreet/DEV" engine-2.0/kubectl.conf
	 sed -i "/contexts:/a\- context:\n    cluster: cc-demo-1\n    user: cc-demo-1\n    namespace: ea-sharedservices-dev\n  name: EA-SharedServices/DEV" engine-2.0/kubectl.conf
   elif [ "$APPZ_ENV" = "ntnx" ]; then
   	 sed -e "/contexts:/a\- context:\n    cluster: microk8s-cluster\n    user: admin\n    namespace: alpha-dev\n  name: alpha/DEV" <  ~/.kube/config > engine-2.0/kubectl.conf   
	 sed -i "/contexts:/a\- context:\n    cluster: microk8s-cluster\n    user: admin\n    namespace: ea-sharedservices-dev\n  name: EA-SharedServices/DEV" engine-2.0/kubectl.conf
   else
         sed -e "/contexts:/a\- context:\n    cluster: kubernetes\n    user: kubernetes-admin\n    namespace: alpha-dev\n  name: alpha/DEV" <  ~/.kube/config > engine-2.0/kubectl.conf
         sed -i "/contexts:/a\- context:\n    cluster: kubernetes\n    user: kubernetes-admin\n    namespace: ea-sharedservices-dev\n  name: EA-SharedServices/DEV" engine-2.0/kubectl.conf
   fi
else
    echo "Missing k8s config, please install k8s and run install.sh again"
    exit 1
fi
if [ $? -eq  0 ]; then
        echo "updated kubectl.conf"
else
        echo "faild to update kubectl.conf"
    exit 1
fi
sudo mv engine-2.0/kubectl.conf /home/appz/volumes/engine-2.0/home/kubectl.conf
if [ $? -eq  0 ]; then
        echo "moved kubectl.conf to "/home/appz/volumes/engine-2.0/home/kubectl.conf""
else
        echo "failed to move kubectl.conf to "/home/appz/volumes/engine-2.0/home/kubectl.conf""
    exit 1
fi
if [ -x "$(command -v kubeadm)" ]; then
  sudo chown -R appz:appz  /home/appz/.kube
fi

trap 'log_report' ERR

docker inspect -f '{{.State.Running}}' engine >/dev/null 2>/dev/null

trap - ERR

if [ $? -eq  0 ]; then
 if [ "$APPZ_ENV" = "alpha" ]; then
     echo "---------"
    echo "configuring k8s..."
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/local-storage.yaml
    docker exec engine kubectl get StorageClass
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/alpha-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/alpha-integration-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/mystatestreet-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/ea-sharedservices-DEV.yaml
    docker exec engine kubectl get namespaces
    echo "---------"
    echo "provisioning volumes claims for vault..."
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pvc-DEV.alpha.yaml
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pvc-DEV.mystatestreet.yaml
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pvc-DEV.ea-sharedservices.yaml
    docker exec engine kubectl apply -f /appz/docker/mongo-3.2/yaml/pvc-DEV.alpha.yaml
    docker exec engine kubectl apply -f /appz/docker/elasticsearch-5.6/yaml/pvc-DEV.alpha.yaml
    docker exec engine kubectl apply -f /appz/docker/graylog-3.0/yaml/pvc-DEV.alpha.yaml
    docker exec engine kubectl -n alpha-dev get pvc
    echo "---------"
    echo "preparing deployment templates..."
    docker exec engine sed -i 's+ubuntu:18.04+'${COMMON_REGISTRY}'/ubuntu:18.04+g' /appz/docker/engine-2.0/yaml/sonarqube8.yaml
 elif [ "$APPZ_ENV" = "ntnx" ]; then
    echo "---------"
    echo "configuring k8s..."
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/local-storage.yaml
    docker exec engine kubectl get StorageClass
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/alpha-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/ea-sharedservices-DEV.yaml
    docker exec engine kubectl get namespaces
    echo "---------"
    echo "provisioning volumes claims for vault..."
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pvc-DEV.ntnx.yaml
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pvc-DEV.ea-sharedservices.ntnx.yaml
    docker exec engine kubectl apply -f /appz/docker/mongo-3.4/yaml/pvc-DEV.ntnx.yaml
    docker exec engine kubectl apply -f /appz/docker/elasticsearch-6.8/yaml/pvc-DEV.ntnx.yaml
    docker exec engine kubectl apply -f /appz/docker/graylog-3.1/yaml/pvc-DEV.ntnx.yaml
    docker exec engine kubectl -n alpha-dev get pvc
    echo "---------"
    echo "preparing deployment templates..."
    docker exec engine sed -i 's+ubuntu:18.04+'${COMMON_REGISTRY}'/ubuntu:18.04+g' /appz/docker/engine-2.0/yaml/sonarqube8.yaml
 else
    echo "---------"
    echo "configuring k8s..."
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/local-storage.yaml
    docker exec engine kubectl get StorageClass
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/alpha-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/ea-sharedservices-DEV.yaml
    docker exec engine kubectl get namespaces
    echo "---------"
    echo "provisioning volumes for vault..."
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pv-DEV."$APPZ_ENV".yaml
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pv-eass-DEV."$APPZ_ENV".yaml
    docker exec engine kubectl apply -f /appz/docker/mongo-3.2/yaml/pv-DEV."$APPZ_ENV".yaml
    docker exec engine kubectl apply -f /appz/docker/elasticsearch-5.6/yaml/pv-DEV."$APPZ_ENV".yaml
    docker exec engine kubectl apply -f /appz/docker/graylog-3.0/yaml/pv-DEV."$APPZ_ENV".yaml
    docker exec engine kubectl get pv
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pvc-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/vault-1.2/yaml/pvc-eass-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/mongo-3.2/yaml/pvc-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/elasticsearch-5.6/yaml/pvc-DEV.yaml
    docker exec engine kubectl apply -f /appz/docker/graylog-3.0/yaml/pvc-DEV.yaml
    docker exec engine kubectl -n alpha-dev get pvc
 fi
else
   echo "Engine is not running. Please rerun install.sh after starting Engine."
   exit 1
fi

result=$( sudo docker images -q appz/ant )
if [[ -n "$result" ]]; then
  docker tag appz/ant:1.10.17 appz/ant:latest
  echo "tag appz/ant successfully"
else
  echo "appz/ant image does not exists"
  exit 1
fi

result=$( sudo docker images -q appz/maven )
if [[ -n "$result" ]]; then
  docker tag appz/maven:3.5.22 appz/maven:latest
  echo "tag appz/maven successfully"
else
  echo "appz/maven image does not exists"
  exit 1
fi

trap 'log_report' ERR

docker inspect -f '{{.State.Running}}' engine >/dev/null 2>/dev/null

trap - ERR

if [ $? -eq  0 ]; then
   if [ "$APPZ_ENV" = "alpha" ]; then

        echo "installing heapster for appz engine"
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/alpha-DEV-influxdb.yaml
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/heapster-rbac.yaml
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/heapster-role.yml
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/alpha-DEV-heapster.yaml

   elif [ "$APPZ_ENV" = "ntnx" ]; then

        echo "installing heapster for appz engine"
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/NTNX-DEV-influxdb.yaml
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/heapster-rbac.yaml
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/heapster-role.yml
        docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/NTNX-DEV-heapster.yaml

   else	   

   	echo "installing heapster for appz engine"
   	docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/influxdb.yaml
   	docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/heapster-rbac.yaml
   	docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/heapster-role.yml
   	docker exec engine kubectl apply -f /appz/docker/engine-2.0/yaml/heapster.yaml
   
   fi
else
   echo "Engine is not running. Please rerun install.sh after starting Engine."
   exit 1
fi
