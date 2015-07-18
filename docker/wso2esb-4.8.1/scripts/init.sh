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

    echo "Configuring WSO2 ESB..."
    echo "Environment variables:"
    printenv
    pushd ${CONFIGURATOR_HOME}
    python configurator.py
    popd
    echo "WSO2 ESB configured successfully"

    echo "Starting WSO2 ESB..."
    CONFIG_PARAM_SUB_DOMAIN=${CONFIG_PARAM_SUB_DOMAIN:-""}
    echo $CONFIG_PARAM_SUB_DOMAIN

    if [ $CONFIG_PARAM_SUB_DOMAIN != "manager" ]; then
        echo "ESB Worker Started .."
        ${CARBON_HOME}/bin/wso2server.sh -DworkerNode=true
    else
        echo "ESB Manager Started .."
        ${CARBON_HOME}/bin/wso2server.sh -Dsetup
    fi
    echo "WSO2 ESB started successfully"
