#!/bin/bash

set -euo pipefail

IMG_DIR=/efs/squash-images
MOUNT_DIR=/opt/compiler-explorer

shopt -s globstar
declare -A mounts
for img_file in "${IMG_DIR}"/**/*.img; do
  dst_path=${img_file/${IMG_DIR}/${MOUNT_DIR}}
  dst_path=${dst_path%.img}
  if mountpoint -q "$dst_path"; then
    echo "$dst_path is mounted already, skipping"
  else
    mounts["$img_file"]="$dst_path"
  fi
done

# If we try and do this in the loop, the mountpoint and mount commands effectively
# serialise and we end up blocking until the whole thing's done.
for img_file in "${!mounts[@]}"; do
  dst_path="${mounts[$img_file]}"
  echo "$img_file -> $dst_path"
  mount -t squashfs "${img_file}" "${dst_path}" -o ro,nodev,relatime &
done
