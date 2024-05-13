#!/bin/bash
set -e

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 373010202891.dkr.ecr.us-east-1.amazonaws.com

# Build the image
docker build --platform=linux/amd64 -t test-open-saas:latest .wasp/build

# Tag the image
docker tag test-open-saas:latest 373010202891.dkr.ecr.us-east-1.amazonaws.com/test-open-saas:latest

# Push the image
docker push 373010202891.dkr.ecr.us-east-1.amazonaws.com/test-open-saas:latest
