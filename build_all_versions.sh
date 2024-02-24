#!/bin/bash

# This script gets the tags from the Telmate/terraform-provider-proxmox repository and builds the container using podman for each version

# Get the tags from the repository
git clone https://github.com/Telmate/terraform-provider-proxmox.git
cd terraform-provider-proxmox || exit
git tag > tags.txt

# Build the container for each version
readarray -t tags < tags.txt

for tag in "${tags[@]}"; do
  echo "================================ Building container for version $tag ================================"
  git checkout "$tag"
  { # try
    podman build -t \
      "docker.io/clincha/terraform-provider-proxmox:$tag" \
      --build-arg VERSION="$tag" \
      --file ../containers/terraform-provider-proxmox.Dockerfile \
      --no-cache \
      . &&
    podman push "docker.io/clincha/terraform-provider-proxmox:$tag" && \
    podman build -t \
      "docker.io/clincha/terraform-provider-proxmox-azrm:$tag" \
      --build-arg VERSION="$tag" \
      --file ../containers/terraform-provider-proxmox-azrm.Dockerfile \
      --no-cache \
      . &&
    podman push "docker.io/clincha/terraform-provider-proxmox-azrm:$tag"
    echo "Successfully built container for version $tag" >> build.log
  } || { # catch
    echo "================================ ERROR: Failed to build container for version $tag ================================"
    echo "Failed to build container for version $tag" >> build.log
  }
  # Delete the images so that we don't run out of storage space on the build agent
  podman rmi "docker.io/clincha/terraform-provider-proxmox:$tag"
  podman rmi "docker.io/clincha/terraform-provider-proxmox-azrm:$tag"
done

echo "================================ Build log ================================"
cat build.log
echo "==========================================================================="

cd .. || exit
rm -rf terraform-provider-proxmox