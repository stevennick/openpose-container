openpose-container
==================

Project files to build openpose container image on L4T platform.


# Supported version matrix
* Openpose v1.6
* JetPack 4.4 DP (L4T r32.4.2)
* cuDNN 8.0.0.145
* CUDA 10.2.89

## Changes
Update cmake cuDNN version detection check files in both Openpose and Caffe project.
It related by newer cuDNN changed its version header file from `cudnn.h` to `cudnn_version.h`

# Execute container notes
## nvidia-container-toolkit fixes
On Jetson devices, current container toolkit has unexpexted directory mount error when mounting cuDNN libraries.
One of the possible solution is use re-orginazed [`cudnn.csv`](https://gist.github.com/stevennick/26ac563fafd02cb29eaefc157d897174) file.
Put the new `cudnn.csv` file under `/etc/nvidia-container-runtime/host-files-for-container.d/` directory and check if cuDNN is correctly mounted.
```=shell
$ wget https://gist.githubusercontent.com/stevennick/26ac563fafd02cb29eaefc157d897174/raw/63546349ff2ace6bbb836c1c869e60985f601ebb/cudnn.csv && sudo mv cudnn.csv /etc/nvidia-container-runtime/host-files-for-container.d/

# check if directory mounted:
$ docker run -it --rm --runtime nvidia openpose-l4t:v1.6-bin ls -l /usr/include/cudnn*
```

## Download models for openpose
Runtime container does not contain download model, it can be mount in runtime via bind mount options.
Run `models/getModel.sh` can download required models.

## Execute container
1. Allow X display server can access by containers:
```=shell
$ sudo xhost +
```
2. Run openpose container with attach `DISPLAY` environment and unix socket:
```=shell
$ docker run -it --rm -v `pwd`/models:/models -v `pwd`/examples/media:/openpose/examples/media stevennick/openpose-l4t:v1.6-bin /bin/bash
```

