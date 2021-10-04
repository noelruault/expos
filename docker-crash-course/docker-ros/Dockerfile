FROM ros:kinetic-ros-core
# https://github.com/osrf/docker_images/blob/49d22242e02e9c541a9e85b657e1785617b6f470/ros/lunar/ubuntu/xenial/ros-core/Dockerfile
MAINTAINER Noel Ruault <contact@noelruault.com>

# UPDATE OS && INSTALL UTILS
RUN apt-get update -y && apt-get upgrade -y \
  && easy_install pip \
  && apt-get install -y \
  qtcreator \
  less tree
  #...

#_____________
# ENVIRONMENT VARIABLES
ENV ROS_WORKSPACE=~/catkin_ws
RUN ls ~/.bashrc || touch ~/.bashrc  # PATCH
RUN echo "export ROS_WORKSPACE=~/catkin_ws" >> ~/.bashrc
ENV ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$ROS_WORKSPACE/
ENV ROSCONSOLE_FORMAT='[${severity}] [${time}]: ${message}'

# RUN ls $ROS_WORKSPACE || mkdir -p $ROS_WORKSPACE/src
RUN ls ~/catkin_ws/src || mkdir -p ~/catkin_ws/src

#______________
# SET-UP WORKSPACE
# RUN mkdir -p $ROS_WORKSPACE/src
# RUN /bin/bash -c '. /opt/ros/$(rosversion -d)/setup.bash; mkdir -p $ROS_WORKSPACE/src && catkin_init_workspace $ROS_WORKSPACE/src'
# RUN /bin/bash -c '. /opt/ros/$(rosversion -d)/setup.bash; cd $ROS_WORKSPACE; catkin_make'
RUN mkdir -p ~/catkin_ws/src
RUN /bin/bash -c '. /opt/ros/$(rosversion -d)/setup.bash; mkdir -p ~/catkin_ws/src && catkin_init_workspace ~/catkin_ws/src'
RUN /bin/bash -c '. /opt/ros/$(rosversion -d)/setup.bash; cd ~/catkin_ws; catkin_make'

RUN echo "source /opt/ros/$(rosversion -d)/setup.bash" >> ~/.bashrc

#---------------

### https://docs.docker.com/engine/reference/builder/#environment-replacement
### https://hub.docker.com/_/ros/

