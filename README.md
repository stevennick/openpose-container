openpose-container
==================

Binary container images for openpose container projects on the L4T platform.

# Supported version matrix
* Openpose v1.6
* JetPack 4.4 DP (L4T r32.4.2)
* cuDNN 8.0.0.145
* CUDA 10.2.89

# Version differences

Those containers are built on top of the NGC container [nvcr.io/nvidia/l4t-base:r32.4.2](https://ngc.nvidia.com/catalog/containers/nvidia:l4t-base), suitable for Jetson platform uses.

* __-bin__ tag: Contains required runtime libraries and python binding for openpose project. This container is suitable for daily uses.
* __-dev__ tag: Contains source codes, prebuilt runtime libraries, headers, python binding, and all required development libraries for openpose project. This container is suitable for development uses.

# Related project pages

* Prebuilt container image: [stevennick/openpose-l4t on Docker Hub](https://hub.docker.com/r/stevennick/openpose-l4t)
* Dockerized project: [stevennick/openpose-container on GitHub](https://github.com/stevennick/openpose-container)
* Modified openpose project: [stevennick/openpose on GitHub](https://github.com/stevennick/openpose)
* Modified Caffe project:[stevennick/caffe on GitHub](https://github.com/stevennick/caffe)

## Changes
Update CMake cuDNN version detection check files in both Openpose and Caffe project.

It related by newer cuDNN changed its version header file from `cudnn.h` to `cudnn_version.h`

# Execute container notes
## nvidia-container-toolkit fixes
On Jetson devices, the current container toolkit has an unexpected directory mount error when mounting cuDNN libraries.
One of the possible solutions is to use re-organized [`cudnn.csv`](https://gist.github.com/stevennick/26ac563fafd02cb29eaefc157d897174) file.
Put the new `cudnn.csv` file under `/etc/nvidia-container-runtime/host-files-for-container.d/` directory and check if cuDNN is correctly mounted.
```=shell
$ wget https://gist.githubusercontent.com/stevennick/26ac563fafd02cb29eaefc157d897174/raw/63546349ff2ace6bbb836c1c869e60985f601ebb/cudnn.csv && sudo mv cudnn.csv /etc/nvidia-container-runtime/host-files-for-container.d/

# check if directory mounted:
$ docker run -it --rm --runtime nvidia openpose-l4t:v1.6-bin ls -l /usr/include/cudnn*
```

## Download models for openpose
Runtime container does not contain models, it can be mount in runtime via bind mount options.

Run `models/getModels.sh` can download required models.

## Execute container
1. Allow X display server can access by containers:
```=shell
$ sudo xhost +
```
2. Run openpose container with attach `DISPLAY` environment and unix socket:
```=shell
$ docker run -it --rm -v `pwd`/models:/models stevennick/openpose-l4t:v1.6-bin /bin/bash

# If want to mount additional media folder inside the container:
$ docker run -it --rm -v `pwd`/models:/models -v `pwd`/examples/media:/openpose/examples/media stevennick/openpose-l4t:v1.6-bin /bin/bash
```

