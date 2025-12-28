# ===============================
# PX4 + AirSim + ROS 2 Humble
# Ubuntu 22.04 (REQUIRED)
# ===============================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# -------------------------------
# Core system utilities
# -------------------------------
RUN apt-get update && apt-get install -y \
    sudo curl wget git nano htop net-tools iputils-ping \
    software-properties-common lsb-release gnupg2 \
    build-essential cmake ninja-build g++ \
    python3 python3-pip python3-venv python3-dev \
    unzip zip pkg-config \
    libtool libxml2-dev libtinyxml2-dev \
    libopencv-dev ffmpeg \
    libboost-all-dev \
    qtbase5-dev qtchooser \
    libqt5widgets5 libqt5gui5 libqt5core5a \
    openjdk-11-jdk \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Add ROS 2 Humble repository (CORRECT WAY)
# -------------------------------
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros2.list

# -------------------------------
# Add Gazebo repository (CORRECT WAY)
# -------------------------------
RUN curl -sSL https://packages.osrfoundation.org/gazebo.key \
    | gpg --dearmor -o /usr/share/keyrings/gazebo-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/gazebo-archive-keyring.gpg] \
    http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/gazebo-stable.list

# -------------------------------
# Install ROS 2 Humble (NO Gazebo yet)
# -------------------------------
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Create non-root user
# -------------------------------
RUN useradd -ms /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devuser
WORKDIR /home/devuser

# -------------------------------
# Python virtual environment
# -------------------------------
RUN python3 -m venv /home/devuser/venv
ENV PATH="/home/devuser/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel && \
    pip install numpy mavsdk==1.3.0 catkin_pkg empy lark-parser

# -------------------------------
# PX4 Autopilot (SITL)
# -------------------------------
RUN git clone https://github.com/PX4/PX4-Autopilot.git --depth=1 && \
    cd PX4-Autopilot && \
    git submodule update --init --recursive

# -------------------------------
# ROS dependency initialization
# -------------------------------
USER root
RUN rosdep init || true && rosdep update
USER devuser

# -------------------------------
# Entrypoint
# -------------------------------
COPY entrypoint.sh /home/devuser/entrypoint.sh
RUN sudo chown devuser:devuser /home/devuser/entrypoint.sh && \
    sudo chmod +x /home/devuser/entrypoint.sh

ENTRYPOINT ["/home/devuser/entrypoint.sh"]
CMD ["bash"]
