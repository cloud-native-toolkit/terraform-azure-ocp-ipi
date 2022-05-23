#!/bin/bash

set -e

INPUT=$(tee)

# echo ${INPUT}

# Get bin_dir to be able to use jq
BIN_DIR=$(echo "${INPUT}" | grep "bin_dir" | sed -E 's/.*"bin_dir": ?"([^"]+)".*/\1/g')

# echo "Binary directory is : ${BIN_DIR}"

# Parse input
eval "$(echo "${INPUT}" | ${BIN_DIR}/jq -r '@sh "LOG_FILE=\(.log_file) KUBECONFIG_FILE=\(.kubeconfig_file)"')"

export KUBECONFIG=${KUBECONFIG_FILE}

CLUSTERID="$(${BIN_DIR}/oc get clusterversion -o jsonpath='{.items[].spec.clusterID}{"\n"}')"

${BIN_DIR}/jq --null-input \
    --arg clusterid "${CLUSTERID}" \
    '{"clusterID": $clusterid}'
