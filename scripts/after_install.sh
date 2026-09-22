#!/bin/bash
set -e

# The ECR repository lives only in us-east-1, regardless of which region
# this instance is deployed in, so we always authenticate against it there.
ECR_REGION="us-east-1"
IMAGE_URI_FILE="/opt/cmtr-5bf61784/image_uri.txt"

if [ ! -f "$IMAGE_URI_FILE" ]; then
  echo "ERROR: ${IMAGE_URI_FILE} not found. Did the build artifact include image_uri.txt?"
  exit 1
fi

IMAGE_URI=$(cat "$IMAGE_URI_FILE")
ECR_REGISTRY=$(echo "$IMAGE_URI" | cut -d'/' -f1)

echo "Logging in to ECR registry ${ECR_REGISTRY} (region ${ECR_REGION})..."
aws ecr get-login-password --region "${ECR_REGION}" | docker login --username AWS --password-stdin "${ECR_REGISTRY}"

echo "Pulling image ${IMAGE_URI}..."
docker pull "${IMAGE_URI}"

echo "Image pulled successfully."
