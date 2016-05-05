#!/bin/bash
# 
set -euf -o pipefail

tfenv=$(basename $(pwd))

# Set up remote state
terraform remote config -backend=s3 \
    -backend-config="bucket=moz-mozreview-state" \
    -backend-config="key=${tfenv}/terraform.tfstate" \
    -backend-config="region=us-west-2"

# Update modules
terraform get
