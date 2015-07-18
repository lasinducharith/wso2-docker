#!/bin/bash
# --------------------------------------------------------------
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# --------------------------------------------------------------

# Start an ESB cluster with docker

DB_USER=root
DB_PASS=root
USER_DB=esb_user_db
REG_DB=esb_reg_db
DB_NAMES=$USER_DB,$REG_DB
DB_MOUNT_DIR=/opt/mysql/data
SLEEP_INTERVAL=10
memberId=1

validateImages(){
# List of required docker images
declare -a arr=("sameersbn/mysql" "krisdavison/svn-server" "lasinducharith/esb")

for i in "${arr[@]}"
do
   IMAGE=$(docker images | grep "$i" |  awk '{print $3}')
    if [[ -z $IMAGE ]]; then
        echo "$i image not found... "
        exit 1
    fi
done
}

startMySQLServer() {
	rm -rf $DB_MOUNT_DIR
	mkdir -p $DB_MOUNT_DIR
	name="esb-mysql-db-server"
	container_id=`docker run --name ${name} -d -e 'DB_USER='"$DB_USER"'' -e 'DB_PASS='"$DB_PASS"'' -e 'DB_NAME='"$DB_NAMES"'' \
	-v ${DB_MOUNT_DIR}:/var/lib/mysql  sameersbn/mysql:latest`
	mysql_ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container_id}`
	echo "ESB MySQL server started: [name] ${name} [ip] ${mysql_ip} [container-id] ${container_id}"
	sleep ${SLEEP_INTERVAL}
}

startSVNServer(){
	# default svn username:password = user:password
	name="esb-dep-sync-svn"
	container_id=`docker run -d -p 81:80 --name ${name} krisdavison/svn-server:v2.0 /startup.sh`
	dep_sync_svn_ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container_id}`
	echo "ESB Dep Sync SVN server started: [name] ${name} [ip] ${dep_sync_svn_ip} [container-id] ${container_id}"
	sleep ${SLEEP_INTERVAL}

}
startWkaMember() {
	name="wso2esb-${memberId}-wka"
	container_id=`docker run -e CONFIG_PARAM_CLUSTERING=true \
	-e CONFIG_PARAM_DEP_SYNC_ENABLED=true \-e CONFIG_PARAM_DEP_SYNC_AUTO_COMMIT=true \
	-e CONFIG_PARAM_DEP_SYNC_SVN_URL=http://${dep_sync_svn_ip}/svn/SampleProject/ \
	-e CONFIG_PARAM_REGISTRY_DB_URL=jdbc:mysql://${mysql_ip}:3306/${REG_DB}?autoReconnect=true \
    -e CONFIG_PARAM_REGISTRY_DB_USER_NAME=${DB_USER} -e CONFIG_PARAM_REGISTRY_DB_PASSWORD=${DB_PASS} \
	-e CONFIG_PARAM_USER_MGT_DB_URL=jdbc:mysql://${mysql_ip}:3306/${USER_DB}?autoReconnect=true \
	-e CONFIG_PARAM_USER_MGT_DB_USER_NAME=${DB_USER} -e CONFIG_PARAM_USER_MGT_DB_PASSWORD=${DB_PASS} \
	-e CONFIG_PARAM_SUB_DOMAIN=manager \
    -d -P --name ${name} lasinducharith/esb:4.8.1`
	memberId=$((memberId + 1))
	wka_member_ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container_id}`
	echo "ESB wka member started: [name] ${name} [ip] ${wka_member_ip} [container-id] ${container_id}"
	sleep ${SLEEP_INTERVAL}
}

startMember() {
	name="wso2esb-${memberId}"
	container_id=`docker run -e CONFIG_PARAM_CLUSTERING=true -e CONFIG_PARAM_WKA_MEMBERS="[${wka_member_ip}:4100]" \
	-e CONFIG_PARAM_DEP_SYNC_ENABLED=true -e CONFIG_PARAM_DEP_SYNC_AUTO_COMMIT=false \
	-e CONFIG_PARAM_DEP_SYNC_SVN_URL=http://${dep_sync_svn_ip}/svn/SampleProject/ \
    -e CONFIG_PARAM_REGISTRY_DB_URL=jdbc:mysql://${mysql_ip}:3306/${REG_DB}?autoReconnect=true \
    -e CONFIG_PARAM_REGISTRY_DB_USER_NAME=${DB_USER} -e CONFIG_PARAM_REGISTRY_DB_PASSWORD=${DB_PASS} \
	-e CONFIG_PARAM_USER_MGT_DB_URL=jdbc:mysql://${mysql_ip}:3306/${USER_DB}?autoReconnect=true \
	-e CONFIG_PARAM_USER_MGT_DB_USER_NAME=${DB_USER} -e CONFIG_PARAM_USER_MGT_DB_PASSWORD=${DB_PASS} \
	-e CONFIG_PARAM_SUB_DOMAIN=worker \
	-d -P --name ${name} lasinducharith/esb:4.8.1`
	memberId=$((memberId + 1))
	member_ip=`docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${container_id}`
	echo "ESB member started: [name] ${name} [ip] ${member_ip} [container-id] ${container_id}"
	sleep 1
}

echo "Starting ESB cluster with docker..."

validateImages
startMySQLServer
startSVNServer
startWkaMember
startMember
startMember
