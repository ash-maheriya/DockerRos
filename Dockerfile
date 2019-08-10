FROM ubuntu:18.04

## Run container as normal user
## Can overrid this from command line during build
ARG user=nvidia
RUN echo ${user}
RUN groupadd --gid 1000 ${user}
RUN useradd  -r --uid 1000 --gid ${user} ${user}

#FROM tensorflow/tensorflow:1.13.1-gpu-py3-jupyter
FROM ros:melodic-robot-bionic
RUN echo "User: " $user

## Install extra packages
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y apt-utils
RUN export DEBIAN_FRONTEND=noninteractive \
         && apt-get install -y sudo vim csh tcsh git curl python3


## Following can be used to install extra python packages
##
### Set the working directory to /app
WORKDIR /app
### Copy the current directory contents into the container at /app
COPY . /app
### Install any needed packages
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3 get-pip.py
RUN pip install --trusted-host pypi.python.org -U pip
##--RUN pip install --trusted-host pypi.python.org Cython
##--RUN pip install --trusted-host pypi.python.org -r requirements.txt
##--RUN pip install --trusted-host pypi.python.org keras
##--RUN pip install --trusted-host pypi.python.org lxml contextlib2
##--RUN pip install tqdm

RUN export DEBIAN_FRONTEND=noninteractive \
         && apt-get install -y ros-melodic-joy

# Make port 80 available to the world outside this container
EXPOSE 8080
EXPOSE 5000
EXPOSE 12222

# Define environment variable
ENV NAME DockerRos
USER ${user}

### Run bash shell when the container launches
CMD ["cd /home/$USER"]
CMD ["/bin/bash"]
