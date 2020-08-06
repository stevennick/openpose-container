FROM nvcr.io/nvidia/l4t-base:r32.4.2 AS develop

LABEL maintainer "Stevennick Ciou <yfciou@itri.org.tw>"

#install build env
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential make python3-pip python3-opencv git libssl-dev libopencv-dev && \
    rm -rf /var/lib/apt/lists/*

#replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.1/cmake-3.18.1.tar.gz && \
    tar xzf cmake-3.18.1.tar.gz -C /opt && \
    rm cmake-3.18.1.tar.gz && \
    cd /opt/cmake-3.18.1 && \
    ./bootstrap && \
    make -j`nproc` && \
    make install && \
    cd /opt && rm -fr /opt/cmake-3.18.1

#get openpose
WORKDIR /openpose
RUN git clone --single-branch --branch v1.6.0-l4t-itri https://github.com/stevennick/openpose.git . && git submodule update --init
COPY CMakeLists.txt /openpose/

#install deps
RUN /bin/sh scripts/ubuntu/install_deps.sh

#build it
WORKDIR /openpose/build

RUN cmake -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D CUDA_HOST_COMPILER=/usr/bin/cc \
          -D CUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda \
          -D CUDA_USE_STATIC_CUDA_RUNTIME=ON \
          -D CUDA_rt_LIBRARY=/usr/lib/aarch64-linux-gnu/librt.so \
          -D GPU_MODE=CUDA \
          -D DOWNLOAD_FACE_MODEL=OFF \
          -D DOWNLOAD_COCO_MODEL=OFF \
          -D USE_OPENCV=ON \
          -D BUILD_PYTHON=ON \
          -D BUILD_EXAMPLES=ON \
          -D BUILD_DOCS=OFF \
          -D DOWNLOAD_HAND_MODEL=OFF \
          .. && \
          make -j`nproc` && \
          make install && \
          mv /usr/local/python/openpose /usr/local/lib/python3.6/dist-packages/ && \
          mv /usr/local/python/pyopenpose* /usr/local/lib/python3.6/dist-packages/

WORKDIR /openpose

FROM nvcr.io/nvidia/l4t-base:r32.4.2 AS runtime

LABEL maintainer "Stevennick Ciou <yfciou@itri.org.tw>"

#install runtime dep
COPY install_runtime_deps.sh .
RUN /bin/sh install_runtime_deps.sh

#install openpose and python libraries
COPY --from=develop /usr/local/lib/libcaffe.so.1.0.0 /usr/local/lib/libcaffe.so.1.0.0 
COPY --from=develop /usr/local/lib/libcaffe.so /usr/local/lib/libcaffe.so 
COPY --from=develop /usr/local/lib/libcaffeproto.a /usr/local/lib/libcaffeproto.a 
COPY --from=develop /usr/local/lib/libopenpose.so.1.6.0 /usr/local/lib/libopenpose.so.1.6.0 
COPY --from=develop /usr/local/lib/libopenpose.so /usr/local/lib/libopenpose.so 
COPY --from=develop /usr/local/lib/libopenpose_3d.so /usr/local/lib/libopenpose_3d.so 
COPY --from=develop /usr/local/lib/libopenpose_calibration.so /usr/local/lib/libopenpose_calibration.so 
COPY --from=develop /usr/local/lib/libopenpose_core.so /usr/local/lib/libopenpose_core.so 
COPY --from=develop /usr/local/lib/libopenpose_face.so /usr/local/lib/libopenpose_face.so 
COPY --from=develop /usr/local/lib/libopenpose_filestream.so /usr/local/lib/libopenpose_filestream.so 
COPY --from=develop /usr/local/lib/libopenpose_gpu.so /usr/local/lib/libopenpose_gpu.so 
COPY --from=develop /usr/local/lib/libopenpose_gui.so /usr/local/lib/libopenpose_gui.so 
COPY --from=develop /usr/local/lib/libopenpose_hand.so /usr/local/lib/libopenpose_hand.so 
COPY --from=develop /usr/local/lib/libopenpose_net.so /usr/local/lib/libopenpose_net.so 
COPY --from=develop /usr/local/lib/libopenpose_pose.so /usr/local/lib/libopenpose_pose.so 
COPY --from=develop /usr/local/lib/libopenpose_producer.so /usr/local/lib/libopenpose_producer.so 
COPY --from=develop /usr/local/lib/libopenpose_thread.so /usr/local/lib/libopenpose_thread.so 
COPY --from=develop /usr/local/lib/libopenpose_tracking.so /usr/local/lib/libopenpose_tracking.so 
COPY --from=develop /usr/local/lib/libopenpose_unity.so /usr/local/lib/libopenpose_unity.so 
COPY --from=develop /usr/local/lib/libopenpose_utilities.so /usr/local/lib/libopenpose_utilities.so 
COPY --from=develop /usr/local/lib/libopenpose_wrapper.so /usr/local/lib/libopenpose_wrapper.so 
COPY --from=develop /usr/local/lib/python3.6/dist-packages/pyopenpose.cpython-36m-aarch64-linux-gnu.so /usr/local/lib/python3.6/dist-packages/pyopenpose.cpython-36m-aarch64-linux-gnu.so 
COPY --from=develop /usr/local/lib/python3.6/dist-packages/openpose/pyopenpose.cpython-36m-aarch64-linux-gnu.so /usr/local/lib/python3.6/dist-packages/openpose/pyopenpose.cpython-36m-aarch64-linux-gnu.so 
COPY --from=develop /usr/local/lib/python3.6/dist-packages/openpose/__init__.py /usr/local/lib/python3.6/dist-packages/openpose/__init__.py

#install openpose test binaries
COPY --from=develop /openpose/build/examples /openpose/build/
RUN mkdir -p /models && \
    ln -s /models /openpose/models
WORKDIR /openpose
