#!/bin/bash

# This script gets the tags from the Telmate/terraform-provider-proxmox repository and builds the container using podman for each version

# Get the tags from the repository
#git clone https://github.com/Telmate/terraform-provider-proxmox.git
#cd terraform-provider-proxmox || exit
#git tag > ../tags.txt

# Build the container for each version
readarray -t a < tags.txt