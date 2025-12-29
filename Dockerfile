# =====================================================
# PX4 + ROS 2 Humble + AirSim (SITL)
# Ubuntu 22.04 (Jammy)
# =====================================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# -----------------------------------------------------
# Core system packages (SAFE, NO ROS/Gazebo YET)
# -----------------------------------------------------
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

# -----------------------------------------------------
# ROS 2 Humble repository (OFFICIAL)
# -----------------------------------------------------
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu jammy main" \
    > /etc/apt/sources.list.d/ros2.list

# -----------------------------------------------------
# Install ROS 2 Humble (NO Gazebo)
# -----------------------------------------------------
RUN apt-get update && apt-get install -y \
    ros-humble-desktop \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------
# Create non-root user
# -----------------------------------------------------
RUN useradd -ms /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devuser
WORKDIR /home/devuser

# -----------------------------------------------------
# Python virtual environment
# -----------------------------------------------------
RUN python3 -m venv /home/devuser/venv
ENV PATH="/home/devuser/venv/bin:$PATH"

# -----------------------------------------------------
# Python deps REQUIRED by PX4 (STRICT versions)
# -----------------------------------------------------
RUN pip install --upgrade pip setuptools wheel && \
    pip install \
    numpy \
    mavsdk==1.3.0 \
    kconfiglib \
    pyyaml \
    jinja2 \
    jsonschema \
    future \
    lxml \
    catkin_pkg \
    lark-parser \
    pyros-genmsg \
    empy==3.3.4

# -----------------------------------------------------
# PX4 Autopilot (SITL)
# -----------------------------------------------------
RUN git clone https://github.com/PX4/PX4-Autopilot.git --depth=1 && \
    cd PX4-Autopilot && \
    git submodule update --init --recursive

# -----------------------------------------------------
# ROS dependency init
# -----------------------------------------------------
USER root
RUN rosdep init || true && rosdep update
USER devuser

# -----------------------------------------------------
# Entrypoint
# -----------------------------------------------------
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh
USER devuser

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
