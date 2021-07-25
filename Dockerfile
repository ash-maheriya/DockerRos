FROM nvcr.io/nvidia/l4t-base:r32.5.0

ENV TZ 'America/Los_Angeles'
ARG user nvidia
ENV ROS_DISTRO melodic
ARG UBUNTU_DISTRO bionic

SHELL ["/bin/bash" , "-c"]

# setup timezone
RUN echo $TZ > /etc/timezone && \
    ln -s /usr/share/zoneinfo/$TZ /etc/localtime && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends tzdata && \
    rm -rf /var/lib/apt/lists/*

# setup environment
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8


RUN apt-get update && apt-get install -y -q --no-install-recommends \
        bash \
        lsb-release \
        sudo \
        less \
        policykit-1 \
        software-properties-common \
        kmod \
        openssl && \
        \
    groupadd --gid 1000 ${user} && \
    useradd -m -u 1000 -g 1000 -s /bin/bash -G input,dialout,adm,sudo,audio,video,plugdev ${user} && \
    echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/users && \
        \
    apt-get install -y \
        debconf-utils \
        dialog \
        dirmngr \
        gnupg2 \
        gpg-agent \
        apt-utils \
        gdebi && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections && \
    apt-get install -y resolvconf && \
        \
    # Install extra packages
    apt-get update && \
    apt-get install -q -y --no-install-recommends \
        build-essential \
        cmake \
        checkinstall \
        pkg-config \
        yasm \
        git \
        vim \
        curl \
        usbutils \
        libusb-dev \
        libftdi-dev \
        libuvc-dev \
        libudev-dev \
        python \
        python-dev \
        python-pip && \
            \
    # OpenCV deps
    apt-get install -q -y --no-install-recommends \
        zlib1g-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libjpeg-turbo8-dev \
        libjpeg8-dev \
        libopenexr-dev \
            \
        # Video I/O:
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libv4l-dev \
        fontconfig \
        libavutil-dev \
        libxvidcore-dev \
        libx264-dev \
            \
        # Gtk and OpenGL
        libgtk2.0-dev \
        libgtkglext1-dev \
        libgtkglextmm-x11-1.2-dev \
        libgles2-mesa-dev \
        mesa-utils \
        libglvnd-dev \
        libgl1-mesa-glx \
        libgl1-mesa-dev \
        libegl1-mesa-dev \
        libcanberra-gtk-module \
            \
        libglx0 \
        libxext6 \
        libx11-6 \
            \
        libsm6 \
        libxrender-dev \
            \
        # Compute
        libeigen3-dev \
        libatlas-base-dev \
        libatlas3-base \
            \
        # Boost 
        libboost-dev \
        libboost-filesystem-dev \
            \
        # Misc
        libpangocairo-1.0-0 \
        libsnappy1v5 \
        libswresample-dev \
        libswscale-dev \
        libvdpau1 \
        libxcb-shm0 \
        libxcb-sync1 \
        libxcb-xfixes0 \
        libxfixes3 \
        libxshmfence1 \
        libxvidcore4 \
            \
        # Gstreamer
        gstreamer1.0-tools gstreamer1.0-alsa \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
            \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-good1.0-dev \
            \
        libopencv-dev \
        python-scipy \
        python-h5py \
        libxml2-dev \
        libxslt1-dev \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup keys
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# ROS packages
RUN echo "deb http://packages.ros.org/ros/ubuntu ${UBUNTU_DISTRO} main" > /etc/apt/sources.list.d/ros1-latest.list && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /home/${user}/.bashrc && \
    apt-get update && \
    apt-get install -q -y --no-install-recommends \
        ros-${ROS_DISTRO}-ros-core && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Bootstrap rosdep and install rest of the ros packages
RUN apt-get update && \
    apt-get install -q -y --no-install-recommends \
        ros-${ROS_DISTRO}-desktop-full \
        ros-${ROS_DISTRO}-robot \
        ros-${ROS_DISTRO}-joy \
        ros-${ROS_DISTRO}-opencv-apps && \
    apt-get install -q -y --no-install-recommends \
        arduino \
        python-rosdep \
        python-rosinstall \
        python-rosinstall-generator \
        python-wstool \
        ros-${ROS_DISTRO}-rosserial-arduino \
        ros-${ROS_DISTRO}-ros-tutorials \
        ros-${ROS_DISTRO}-rosserial \
        ros-${ROS_DISTRO}-angles && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install any needed python packages
#    python -m pip install scikit-learn && \

RUN python -m pip install -U \
        pip && \
    python -m pip install -U \
        setuptools \
        wheel && \
    python -m pip install \
        Cython && \
    python -m pip install \
        numpy \
        matplotlib \
        Pillow \
        requests \
        psutil \
        flask \
        flask-httpauth \
        six \
        lxml \
        contextlib2 \
        tqdm

RUN rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO

# Define environment variable
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
ENV NAME DockerRos ros-calib
USER ${user}
WORKDIR /home/${user}

# Setup entrypoint
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

