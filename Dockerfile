FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG DEV_USER_NAME=Zephyr-microPlatform
ARG DEV_USER=zmp-dev
ARG DEV_USER_PASSWD=zmp

ENV ZEPHYR_TOOLCHAIN_VARIANT=gnuarmemb
ENV GNUARMEMB_TOOLCHAIN_PATH=/opt/gcc-arm-none-eabi-8-2018-q4-major


# Packages needed or useful for Zephyr microPlatform development.
#
# We manage most these in a PPA, and keep them installed. Some Python
# dependencies can't be satisfied with Ubuntu 16.04 packages, and are
# installed via pip3.
#
# Refer here for details on the hash -r:
# https://github.com/pypa/pip/issues/5221#issuecomment-382069604
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   software-properties-common \
	&& add-apt-repository ppa:fio-maintainers/ppa \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends zmp-dev wget \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& pip3 install --upgrade pip \
	&& hash -r \
	&& pip3 install wheel \
	&& pip3 install west \
	&& pip3 install pyelftools cryptography intelhex pyserial click colorama \
	&& wget -O /tmp/sdk.tar.bz2 --progress=dot -e dotbytes=2M 'https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2?revision=d830f9dd-cd4f-406d-8672-cca9210dd220?product=GNU%20Arm%20Embedded%20Toolchain,64-bit,,Linux,8-2018-q4-major' \
	&& tar -C /opt -xf /tmp/sdk.tar.bz2 \
	&& rm /tmp/sdk.tar.bz2



# Add CI dependencies
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		python3-requests \
	&& pip3 install sphinxcontrib-contentui \
	&& wget -O /tmp/install-rust.sh https://sh.rustup.rs \
	&& chmod +x /tmp/install-rust.sh \
	&& apt-get install -y --no-install-recommends curl \
	&& /tmp/install-rust.sh -y \
	&& pip3 install pykwalify \
	&& apt-get purge -y --auto-remove curl \
	&& rm /tmp/install-rust.sh \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Zephyr files are encoded in UTF-8. We don't want the default POSIX
# locale, because that breaks Zephyr tooling like sanitycheck.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends locales \
	&& locale-gen en_US.UTF-8 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

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
