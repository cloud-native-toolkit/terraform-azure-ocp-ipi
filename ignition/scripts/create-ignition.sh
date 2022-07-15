#!/bin/bash

${BIN_DIR}/openshift-install --dir ${INSTALL_PATH} create ignition-configs --log-level=debug
${BIN_DIR}/jq --arg cluster_name "$CLUSTER_INFRA_NAME" '.infraID=$cluster_name' ${INSTALL_PATH}/metadata.json > _metadata.json
mv _metadata.json ${INSTALL_PATH}/metadata.json