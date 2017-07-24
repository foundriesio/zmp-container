FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_USER_NAME=Genesis
ARG DEV_USER=genesis-dev
ARG DEV_USER_PASSWD=genesis

ENV ZEPHYR_GCC_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-v0.9

# Packages needed or useful for Genesis development.
#
# We manage most these in a PPA, and keep them installed. Some Python
# dependencies needed for non-CI development that can't be satisfied
# with Ubuntu 16.04 packages are installed via pip; see below.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   software-properties-common \
	&& add-apt-repository ppa:linaro-maintainers/ltd \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends genesis-dev \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Install the Zephyr SDK and Zephyr's Python dependencies.
RUN apt-get update && apt-get install --no-install-recommends -y \
	file \
	xz-utils \
	wget \
	&& wget -q -O /tmp/zephyr-sdk-setup.run https://github.com/zephyrproject-rtos/meta-zephyr-sdk/releases/download/0.9.1/zephyr-sdk-0.9.1-setup.run \
	&& chmod +x /tmp/zephyr-sdk-setup.run \
	&& /tmp/zephyr-sdk-setup.run --quiet -- -d $ZEPHYR_SDK_INSTALL_DIR -y \
	&& apt-get purge -y --auto-remove \
		file \
		xz-utils \
		wget \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/zephyr-sdk-0.9-setup.run \
	&& pip3 install --system pyelftools

# Add CI dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		python3-requests \
		qemu-system-arm \
		wget \
	&& wget -O /tmp/install-rust.sh https://sh.rustup.rs \
	&& chmod +x /tmp/install-rust.sh \
	&& apt-get install -y --no-install-recommends curl \
	&& /tmp/install-rust.sh -y \
	&& easy_install3 pykwalify \
	&& apt-get purge -y --auto-remove curl \
	&& rm /tmp/install-rust.sh \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Create the user which will run the SDK binaries.
RUN useradd -c $DEV_USER_NAME \
		-d /home/$DEV_USER \
		-G sudo,dialout,floppy,plugdev,users \
		-m \
		-s /bin/bash \
		$DEV_USER

# Add default password for the SDK user (useful with sudo)
RUN echo $DEV_USER:$DEV_USER_PASSWD | chpasswd

# Initialize development environment for $DEV_USER.
RUN sudo -u $DEV_USER -H git config --global credential.helper 'cache --timeout=3600'
