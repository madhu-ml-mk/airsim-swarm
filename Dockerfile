FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    curl git python3-pip python3-venv build-essential cmake wget lsb-release \
    gnupg2 software-properties-common locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list && \
    apt-get update && apt-get install -y ros-humble-desktop python3-rosdep python3-colcon-common-extensions && \
    rosdep init || true && rosdep update || true
RUN apt-get install -y ninja-build python3-empy python3-toml python3-numpy \
    python3-yaml protobuf-compiler libeigen3-dev libopencv-dev
RUN pip3 install --no-cache-dir --upgrade pip setuptools wheel
RUN pip3 install --no-cache-dir numpy pandas torch torchvision torchaudio cpuonly \
    jupyterlab opencv-python-headless mavsdk requests
RUN useradd -ms /bin/bash devuser
USER devuser
WORKDIR /home/devuser
RUN mkdir -p ros2_ws/src
COPY entrypoint.sh /home/devuser/entrypoint.sh
RUN chmod +x /home/devuser/entrypoint.sh
ENTRYPOINT ["/home/devuser/entrypoint.sh"]
CMD ["bash"]
