#!/bin/bash

echo "Bin_dir = ${BIN_DIR}"
echo "Install_path = ${INSTALL_PATH}"
echo "CLUSTER_INFRA_NAME = ${CLUSTER_INFRA_NAME}"

${BIN_DIR}/openshift-install --dir ${INSTALL_PATH} create ignition-configs --log-level=debug
${BIN_DIR}/jq --arg cluster_name "$CLUSTER_INFRA_NAME" '.infraID=$cluster_name' ${INSTALL_PATH}/metadata.json > _metadata.json
mv _metadata.json ${INSTALL_PATH}/metadata.json