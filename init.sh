#!/bin/bash
# 
set -euf -o pipefail

tfenv=$(basename $(pwd))

# Set up remote state
terraform init -backend-config="key=${tfenv}/terraform.tfstate"

# Update modules
terraform get
