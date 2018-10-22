#!/bin/bash
gcloud compute instances create reddit-app --image-family=reddit-full --image-project=infra-219315 --tags puma-server
