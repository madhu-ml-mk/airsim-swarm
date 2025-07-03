FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Base tools and locales
RUN apt-get update && apt-get install -y \
    curl git python3-pip python3-venv build-essential cmake wget lsb-release \
    gnupg2 software-properties-common locales ca-certificates sudo && \
    locale-gen en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Fix keyring method (no apt-key)
RUN mkdir -p /etc/apt/keyrings && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /etc/apt/keyrings/ros-archive-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list

# Fix broken security source (replace security.ubuntu.com)
RUN sed -i 's|http://security.ubuntu.com|http://archive.ubuntu.com|g' /etc/apt/sources.list && apt-get update

# Install ROS2 and tools
RUN apt-get install -y ros-humble-desktop python3-rosdep python3-colcon-common-extensions && \
    rosdep init || true && rosdep update || true

# AirSim/AI-related dependencies
RUN apt-get install -y ninja-build python3-empy python3-toml python3-numpy \
    python3-yaml protobuf-compiler libeigen3-dev libopencv-dev

# Python venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install Python dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install numpy pandas torch torchvision torchaudio \
    jupyterlab opencv-python-headless mavsdk requests

# Create root password
RUN echo "root:root123" | chpasswd

# Create non-root user and password
RUN useradd -ms /bin/bash devuser && echo "devuser:devuser123" | chpasswd && \
    usermod -aG sudo devuser

# Entrypoint for devuser
COPY entrypoint.sh /home/devuser/entrypoint.sh
RUN chown devuser:devuser /home/devuser/entrypoint.sh && chmod +x /home/devuser/entrypoint.sh

USER devuser
WORKDIR /home/devuser
RUN mkdir -p ros2_ws/src

ENTRYPOINT ["/home/devuser/entrypoint.sh"]
CMD ["bash"]
