#!/bin/bash

# Start the container to run as the development user, with some host
# filesystem volume mounts in /mnt.

dev_user=genesis-dev
container=genesis-sdk

docker run --rm -ti \
	-u "$dev_user" \
	-v "$HOME:/mnt/host-home" \
	-v "/:/mnt/host-root" \
	-w "/home/$dev_user" \
	"$container" \
	bash -l
