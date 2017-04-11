FROM ubuntu:16.04
MAINTAINER Marti Bolivar <marti.bolivar@linaro.org>

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_USER_NAME=Genesis
ARG DEV_USER=genesis-dev

ENV ZEPHYR_GCC_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-v0.9

# Packages needed or useful for Genesis development. We keep these around.
#
# Zephyr packages from
# https://www.zephyrproject.org/doc/getting_started/installation_linux.html
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		git \
		make \
		gcc \
		gcc-multilib \
		g++ \
		g++-multilib \
		libc6-dev-i386 \
		bzip2 \
		libncurses5-dev \
		python-yaml \
		python3 \
		python3-setuptools \
		python3-pip \
		python3-ply \
		python3-yaml \
		libpython3.5-dev \
		repo \
		ca-certificates \
		sudo \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install the Zephyr SDK.
RUN apt-get update && apt-get install --no-install-recommends -y \
	file \
	wget \
	xz-utils \
	&& wget -q -O /tmp/zephyr-sdk-0.9-setup.run https://nexus.zephyrproject.org/content/repositories/releases/org/zephyrproject/zephyr-sdk/0.9/zephyr-sdk-0.9-setup.run \
	&& chmod +x /tmp/zephyr-sdk-0.9-setup.run \
	&& /tmp/zephyr-sdk-0.9-setup.run --quiet -- -d $ZEPHYR_SDK_INSTALL_DIR -y \
	&& apt-get purge -y --auto-remove \
		file \
		wget \
		xz-utils \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/zephyr-sdk-0.9.setup.run

# Create the user which will run the SDK binaries.
RUN useradd -c $DEV_USER_NAME \
		-d /home/$DEV_USER \
		-G sudo,dialout,floppy,plugdev,users \
		-m \
		-s /bin/bash \
		$DEV_USER

# Initialize development environment for $DEV_USER.
RUN sudo -u $DEV_USER -H pip3 install --user wheel \
	&& sudo -u $DEV_USER -H pip3 install --user pycrypto \
	&& sudo -u $DEV_USER -H git config --global credential.helper cache \
	&& sudo -u $DEV_USER -H git config --global credential.helper 'cache --timeout=3600'
