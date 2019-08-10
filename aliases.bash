## aliases for building and running docker images
## port mapping -p <host>:<docker>
alias a=alias
dcr_name="ros/python:melodic"
a dbuild="docker build --build-arg user=$USER -t $dcr_name ."
a dcr_ros="nvidia-docker run --rm -it \
        -p 8080:8080 -p 5000:5000 -p 12222:12222 \
        --group-add sudo \
        --env=DISPLAY         \
        --volume=/etc/group:/etc/group:ro             \
        --volume=/etc/passwd:/etc/passwd:ro           \
        --volume=/etc/shadow:/etc/shadow:ro           \
        --volume=/etc/sudoers.d:/etc/sudoers.d:ro     \
        --volume=/tmp/.X11-unix:/tmp/.X11-unix:rw     \
        --volume=/home/${USER}:/home/${USER}          \
        --user ${UID}:${UID}                          \
        --ipc=host $dcr_name "

        #--volume="/IMAGESETS:/IMAGESETS"                \

#EOF
