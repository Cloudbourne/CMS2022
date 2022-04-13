#!/bin/bash

cwd=$(pwd)

images=( ubuntu-18.04 wordpress-5.2 mariadb-10.4 mariadb-10.4_master mariadb-10.4_slave wordpress-5.2_ha vault-1.2 filesync wordpress-5.3 wordpress-5.3_ha )

for i in "${images[@]}"
do
	echo ----------------------- building $i ----------------------- 
	cd ../$i
	bash -c "../build.sh"
	
done

cd $cwd
