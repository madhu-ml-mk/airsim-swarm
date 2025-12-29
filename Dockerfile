# ===============================
# PX4 + AirSim + ROS 2 Humble
# Ubuntu 22.04
# ===============================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV PATH="/home/devuser/venv/bin:$PATH"

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
# Add ROS 2 Humble repository
# -------------------------------
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
    | gpg --dearmor -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] \
    http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/ros2.list

# -------------------------------
# Install ROS 2 Humble
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

# Upgrade pip & preinstall PX4 Python dependencies
RUN /home/devuser/venv/bin/pip install --upgrade pip setuptools wheel && \
    /home/devuser/venv/bin/pip install \
        pyserial empy toml kconfiglib pandas numpy pyulog \
        catkin_pkg lark-parser

# -------------------------------
# PX4 Autopilot (SITL)
# -------------------------------
RUN git clone https://github.com/PX4/PX4-Autopilot.git --depth=1 && \
    /home/devuser/venv/bin/pip install -r PX4-Autopilot/Tools/setup/requirements.txt

# -------------------------------
# ROS dependency initialization
# -------------------------------
USER root
RUN rosdep init || true && rosdep update
USER devuser

# -------------------------------
# Pre-build PX4 SITL (cached)
# -------------------------------
RUN cd /home/devuser/PX4-Autopilot && \
    DONT_RUN=1 make px4_sitl_default none_iris

# -------------------------------
# Entrypoint
# -------------------------------
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
USER devuser

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
