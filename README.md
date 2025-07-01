# AirSim Swarm AI Development Environment

## Overview
This repository contains a Dockerized development environment for AI-based drone swarm projects with ROS2, PX4, AirSim, and PyTorch.

## Features
- Ubuntu 22.04 base
- ROS2 Humble Desktop
- PX4 dependencies for SITL simulation
- AirSim Python RPC client
- PyTorch with GPU support and CPU fallback
- JupyterLab + VSCode Remote support

## Running the Container
```bash
docker compose up --build
```
Access the container:
```bash
docker exec -it airsim-swarm-dev bash
```

## Moving WSL2 to Another Drive
```powershell
wsl --export <distro_name> V:\WSL\ubuntu.tar
wsl --unregister <distro_name>
wsl --import <distro_name> V:\WSL\Ubuntu-22.04 V:\WSL\ubuntu.tar --version 2
```
