#FROM ubuntu:18.04
#FROM tensorflow/tensorflow:1.13.1-gpu-py3-jupyter
FROM ros:melodic-robot-bionic

## Run container as normal user
## Can overrid this from command line during build
ARG user=nvidia
RUN groupadd --gid 1000 ${user} && \
    groupadd --gid 104 input && \
    useradd  -r --uid 1000 --gid ${user} ${user}
##RUN usermod -aG input,dialout,adm,sudo,audio,video,plugdev ${user}

#ARG user=ros
#ARG passwd=ros
#ARG uid=1000
#ARG gid=1000
#ENV USER=$user
#ENV PASSWD=$passwd
#ENV UID=$uid
#ENV GID=$gid
#RUN useradd --create-home -m $USER && \
#        echo "$USER:$PASSWD" | chpasswd && \
#        usermod --shell /bin/bash $USER && \
#        usermod -aG sudo $USER && \
#        echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USER && \
#        chmod 0440 /etc/sudoers.d/$USER && \
#        # Replace 1000 with your user/group id
#        usermod  --uid $UID $USER && \
#        groupmod --gid $GID $USER

RUN echo "User: ${user}"


## Install extra packages (includes OpenCV dependencies)
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y apt-utils
RUN export DEBIAN_FRONTEND=noninteractive && \
        apt-get install -y sudo vim csh tcsh git curl python python-dev python-scipy && \
        apt-get install -y libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 \
            libtbb-dev libtbb2 libgtk2.0-0 libgtk2.0-dev
RUN export DEBIAN_FRONTEND=noninteractive && \
        apt-get install -y build-essential cmake checkinstall pkg-config \
            zlib1g-dev libjpeg-dev libpng-dev \
            libfreetype6-dev \
            libavcodec-dev libavformat-dev libswscale-dev yasm libv4l-dev \
            libeigen3-dev \
            libatlas3-base libatlas-base-dev \
            libboost-dev libboost-filesystem-dev \
            libprotobuf-dev protobuf-compiler python-protobuf \
            libgoogle-glog-dev libgflags-dev libhdf5-dev liblmdb-dev liblmdb0 lmdb-doc \
            libsnappy-dev libleveldb-dev python-leveldb libleveldb1v5

WORKDIR /app
### Copy the current directory contents into the container at /app
COPY . /app
RUN dpkg -i libopencv_3.3.1-2-g31ccdfe11_arm64.deb && \
    dpkg -i libopencv-dev_3.3.1-2-g31ccdfe11_arm64.deb && \
    dpkg -i libopencv-samples_3.3.1-2-g31ccdfe11_arm64.deb && \
    dpkg -i libopencv-python_3.3.1-2-g31ccdfe11_arm64.deb && \
    echo "OpenCV installed!"
RUN rm -f libopencv*
 
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y ros-melodic-joy 
RUN export DEBIAN_FRONTEND=noninteractive \
        && apt-get install -y arduino \
        && apt-get install -y python-rosinstall python-rosinstall-generator python-wstool \
        && apt-get install -y ros-melodic-rosserial-arduino ros-melodic-rosserial ros-melodic-angles


## Following can be used to install extra python packages
##
##--### Set the working directory to /app
##--WORKDIR /app
##--### Copy the current directory contents into the container at /app
##--COPY . /app
### Install any needed packages
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python get-pip.py
RUN pip install --trusted-host pypi.python.org -U pip
RUN pip install --trusted-host pypi.python.org Cython
RUN pip install --trusted-host pypi.python.org -r requirements.txt
#RUN pip install --trusted-host pypi.python.org keras
RUN pip install --trusted-host pypi.python.org lxml contextlib2
RUN pip install tqdm

# Make port 80 available to the world outside this container
EXPOSE 8080
EXPOSE 5000
EXPOSE 12222

# Define environment variable
ENV NAME DockerRos
USER ${user}
WORKDIR /home/${user}

### Run bash shell when the container launches
CMD ["/bin/bash"]
