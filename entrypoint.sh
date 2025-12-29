#!/usr/bin/env bash
set -e

source /home/devuser/venv/bin/activate

echo "Starting PX4 SITL (AirSim mode)..."

cd /home/devuser/PX4-Autopilot
make px4_sitl_default none_iris

exec bash
