#!/usr/bin/env bash

ENABLED=$(cat .enabled)

if [[ "${ENABLED}" == "false" ]]; then
  echo "The resource group is not enabled."
fi

echo "Terraform state:"
terraform state list