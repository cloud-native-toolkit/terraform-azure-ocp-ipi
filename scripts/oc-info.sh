#!/bin/bash

set -e

INPUT=$(tee)

# echo ${INPUT}

# Get bin_dir to be able to use jq
BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]+)".*/\1/g')

# echo "Binary directory is : ${BIN_DIR}"

# Parse input
eval "$(echo "${INPUT}" | ${BIN_DIR}/jq -r '@sh "LOG_FILE=\(.log_file) METADATA_FILE=\(.metadata_file)"')"

# Set config file path
CONFIGPATH="$(pwd ${LOG_FILE})"

# Get console URL info from the log file
CONSOLEURL=$(cat ${LOG_FILE} | grep "https://console-openshift-console" | tail -1 | egrep -o 'https?://[^ ]+' | sed 's/"//g')

# Get server URL info from the kubeconfig file

# Get credentials from the log file
USER=$(cat ${LOG_FILE} | grep "and password" | tail -1 | egrep -o 'user:[^,]+' | sed 's/\\"//g' | awk '{print $2}')
PWD=$(cat ${LOG_FILE} | grep "and password" | tail -1 | egrep -o 'password:[^,]+' | sed 's/\\"//g' | sed 's/"//g' | awk '{print $2}')

# Get the cluster id and infra id from the metadata
eval "$(cat ${METADATA_FILE} | ${BIN_DIR}/jq -r '@sh "CLUSTERID=\(.clusterID) INFRAID=\(.infraID)"')"

${BIN_DIR}/jq --null-input \
    --arg consoleurl "${CONSOLEURL}" \
    --arg user "${USER}" \
    --arg pwd "${PWD}" \
    --arg clusterid "${CLUSTERID}" \
    --arg infraid "${INFRAID}" \
    '{"consoleURL": $consoleurl, "kubeadminUsername": $user, "kubeadminPassword": $pwd, "clusterID": $clusterid, "infraID": $infraid}'
