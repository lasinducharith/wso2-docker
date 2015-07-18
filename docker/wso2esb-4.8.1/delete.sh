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

# Delete the ESB docker cluster
memberId=1
deleteMySQLServer(){
	name="esb-mysql-db-server"
	docker rm ${name}
	echo "ESB MySQL Server deleted: [name] ${name}"
	sleep 1
}
deleteSVNServer() {
	name="esb-dep-sync-svn"
	docker rm ${name}
	echo "ESB Dep-sync SVN Server deleted: [name] ${name}"
	sleep 1

}
deleteWkaMember() {
	name="wso2esb-${memberId}-wka"
	docker rm ${name}
	memberId=$((memberId + 1))
	echo "ESB wka member deleted: [name] ${name}"
	sleep 1
}

deleteMember() {
	name="wso2esb-${memberId}"
	docker rm ${name}
	memberId=$((memberId + 1))
	echo "ESB member deleted: [name] ${name}"
	sleep 1
}

echo "Deleting ESB docker cluster..."

deleteMySQLServer
deleteSVNServer
deleteWkaMember
deleteMember
deleteMember