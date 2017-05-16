FROM ubuntu:16.04
MAINTAINER Marti Bolivar <marti.bolivar@linaro.org>

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_USER_NAME=Genesis
ARG DEV_USER=genesis-dev

ENV ZEPHYR_GCC_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-v0.9

# Packages needed or useful for Genesis development.
# We manage these in a PPA, and keep them installed.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   software-properties-common \
	&& add-apt-repository ppa:linaro-maintainers/ltd \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends genesis-dev \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Add CI dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		python3-requests \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install the Zephyr SDK.
RUN apt-get update && apt-get install --no-install-recommends -y \
	file \
	xz-utils \
	wget \
	&& wget -q -O /tmp/zephyr-sdk-0.9-setup.run https://nexus.zephyrproject.org/content/repositories/releases/org/zephyrproject/zephyr-sdk/0.9/zephyr-sdk-0.9-setup.run \
	&& chmod +x /tmp/zephyr-sdk-0.9-setup.run \
	&& /tmp/zephyr-sdk-0.9-setup.run --quiet -- -d $ZEPHYR_SDK_INSTALL_DIR -y \
	&& apt-get purge -y --auto-remove \
		file \
		xz-utils \
		wget \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/zephyr-sdk-0.9-setup.run

# Create the user which will run the SDK binaries.
RUN useradd -c $DEV_USER_NAME \
		-d /home/$DEV_USER \
		-G sudo,dialout,floppy,plugdev,users \
		-m \
		-s /bin/bash \
		$DEV_USER

# Initialize development environment for $DEV_USER.
RUN sudo -u $DEV_USER -H git config --global credential.helper 'cache --timeout=3600'
