FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PX4_AUTOSTART=1

# -------------------------------
# Core system packages (PX4 only)
# -------------------------------
RUN apt-get update && apt-get install -y \
    sudo curl wget git nano \
    build-essential cmake ninja-build g++ \
    python3 python3-pip python3-dev python3-venv \
    pkg-config \
    libxml2-dev libxslt1-dev \
    net-tools iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# User
# -------------------------------
RUN useradd -ms /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER devuser
WORKDIR /home/devuser

# -------------------------------
# Python venv (PX4 safe)
# -------------------------------
RUN python3 -m venv /home/devuser/venv
ENV PATH="/home/devuser/venv/bin:$PATH"

RUN pip install --upgrade pip setuptools wheel && \
    pip install \
    numpy \
    mavsdk \
    empy==3.3.4 \
    jinja2 \
    lark-parser \
    pyros-genmsg \
    catkin_pkg \
    pyyaml \
    kconfiglib \
    jsonschema \
    lxml


# -------------------------------
# PX4 Autopilot
# -------------------------------
RUN git clone https://github.com/PX4/PX4-Autopilot.git && \
    cd PX4-Autopilot && \
    git submodule update --init --recursive

# Entrypoint
USER root
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# 🔐 HARD FIX: strip BOM + force LF
RUN sed -i '1s/^\xEF\xBB\xBF//' /usr/local/bin/entrypoint.sh && \
    sed -i 's/\r$//' /usr/local/bin/entrypoint.sh && \
    chmod +x /usr/local/bin/entrypoint.sh

USER devuser
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
