![](https://img.shields.io/github/license/open-horizon-services/service-yolo-cuda)
![](https://img.shields.io/badge/architecture-arm64%2C%20amd64%2C%20arm%2C%20amd-green)
![](https://img.shields.io/github/contributors/open-horizon-services/service-yolo-cuda)

# service-yolo-cuda

Open Horizon service container demonstrating You Only Look Once (YOLO) integration with ROS and CUDA GPU.

This is an Open Horizon configuration to deploy an instance of YOLO, a real time object detection algorithm commonly used in the localization task, with CUDA accelerated GPU computation as a ROS package.

YOLO ROS is a package developed for **object detection in camera images** and is able to detect pre-trained classes including the data set from VOC and COCO, or also a network with custom detection objects.

![image](https://user-images.githubusercontent.com/62410569/203176060-3fb2e4a3-f334-42eb-86d4-1fabd9218a5d.png)

## Requirements

* **darknet_ros:** YOLO is built on the Robotic Operating System (ROS), which must be installed. Follow the installation instructions on the The official YOLO ROS wrapper GitHub repo [darknet_ros](https://github.com/leggedrobotics/darknet_ros). darknet_ros currently only supports YOLOv3 and below. If YOLOv4 is being used instead, follow the guide on this [repository](https://github.com/tom13133/darknet_ros/tree/yolov4) instead. 

* **ROS:** Melodic

* **Ubuntu:** 18.04

* **OpenCV:** computer vision library

* **boost:** c++ library

## Installation

Create a catkin workspace and clone the [darknet_ros](https://github.com/leggedrobotics/darknet_ros) repository into the catkin workspace **using SSH**. 
```
cd catkin_workspace/src
git clone --recursive git@github.com:leggedrobotics/darknet_ros.git
cd ../
```
> **Note** Make sure you have the --recursive tag when cloning the darknet_ros repo.

Build by setting

`catkin_make -DCMAKE_BUILD_TYPE=Release`

or by using the [Catkin Command Line Tools](https://catkin-tools.readthedocs.io/en/latest/index.html)

`catkin build darknet_ros -DCMAKE_BUILD_TYPE=Release`

### Using your own detection models

To use your own detection objects, you must add your own .cfg and .weights into the /cfg and /weights folders
```
catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/weights/
catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/cfg/
```
Within /cfg, run `dos2unix your_model.cfg` (convert it to Unix format if you have problem with Windows to Unix format transformation).

Modify “ros.yaml” with the correct camera topic and create “your_model.yaml” to configure the model files and detected classes inside:

    catkin_workspace/src/darknet_ros/darknet_ros/config/
Within `catkin_workspace/src/darknet_ros/darknet_ros/yolo_network_config/launch/` modify “darknet_ros.launch” with the correct YAML file (“your_model.yaml”).

Now input the following commands to run the software:
```
catkin_make
source devel/setup.bash
roslaunch darknet_ros darknet_ros.launch
```
After launching the ROS node, a window will automatically appear that will show the RGB stream and detected objects. You can also check the stream in [RVIZ](http://wiki.ros.org/rviz).

## Usage

To have YOLO ROS: Real-Time Object Detection for ROS to run with the desired robot, a few parameters must be adapted. It is simplest if you duplicate and adapt
all the parameter files that you need change from the `darknet_ros` repo package; specifically the parameter files in `config` and and the launch file from `launch`
folder. 

## Advanced Details

### All Makefile targets

* `run` - manually run the container locally as a test
* `stop` - halt a locally-run container
* `dev` - manually run locally and connect to a terminal in the container
* `clean` - remove the container image and docker volume
* `build` - build the container
* `publish-service` - Publish the service definition file to the hub in your organization
* `publish-pattern` - Publish the pattern definition file to the hub in your organization
* `agent-run` - register your agent's [node policy](https://github.com/open-horizon/examples/blob/master/edge/services/helloworld/PolicyRegister.md#node-policy) with the hub
* `agent-stop` - unregister your agent with the hub, halting all agreements and stopping containers
