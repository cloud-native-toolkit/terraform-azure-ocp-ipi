#!/bin/bash

set -e

INPUT=$(tee)

# echo ${INPUT}

# Get bin_dir to be able to use jq
BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]+)".*/\1/g')

# echo "Binary directory is : ${BIN_DIR}"

# Parse input
eval "$(echo "${INPUT}" | ${BIN_DIR}/jq -r '@sh "LOG_FILE=\(.log_file) KUBECONFIG_FILE=\(.kubeconfig_file)"')"

SERVER_URL="$(${BIN_DIR}/yq4 eval '.clusters[].cluster.server' ${KUBECONFIG_FILE})"

# No server token available post cluster creation until first login
SERVER_TOKEN=""

export KUBECONFIG=${KUBECONFIG_FILE}

CLUSTERID="$(${BIN_DIR}/oc get clusterversion -o jsonpath='{.items[].spec.clusterID}{"\n"}')"
SERVER_VERSION="$(${BIN_DIR}/oc get clusterversion -o jsonpath='{.items[].status.history[].version}{"\n"}')"

${BIN_DIR}/jq --null-input \
    --arg clusterid "${CLUSTERID}" \
    --arg serverurl "${SERVER_URL}" \
    --arg server_token "${SERVER_TOKEN}" \
    --arg server_version "${SERVER_VERSION}" \
    '{"clusterID": $clusterid, "serverURL": $serverurl, "serverVersion": $server_version, "serverToken": $server_token}'
