#!/bin/bash

xhost +local:

#  --entrypoint bash \
#
#  --volume=/home/${USER}:/home/${USER}:rw       \
#  --volume=/home/${USER}/ros-calib:/home/${USER}/ros-calib:rw \
#  --user $(id -u):$(id -g)          \
#  --user root \
#  --user $(id -u):$(id -g)          \
#  --shm-size=4g \

docker run -it --rm --runtime nvidia --gpus all \
    \
  --network="host" \
  --ulimit memlock=-1 \
  --ipc=host \
  --privileged \
    \
  --volume=/home/${USER}:/home/${USER}:rw       \
  --volume=/dev/bus/usb:/dev/bus/usb/ \
  --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw \
    \
  -e DISPLAY \
  -e QT_X11_NO_MITSHM=1 \
  -e XAUTHORITY=/tmp/Xauthority \
    \
  --name ros-calib \
  "ros/melodic-perceptive-robot:latest"

##sudo docker run -it --rm --net=host --runtime nvidia \
##    -e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix nvcr.io/nvidia/l4t-base:r32.5.0

