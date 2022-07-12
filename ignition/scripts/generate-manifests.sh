#!/bin/bash

"${BIN_DIR}"/openshift-install --dir="${INSTALL_DIR}" create manifests --log-level=debug
rm "${INSTALL_DIR}"/openshift/99_openshift-cluster-api_worker-machineset-*
rm "${INSTALL_DIR}"/openshift/99_openshift-cluster-api_master-machines-*