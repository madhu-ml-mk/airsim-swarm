#!/usr/bin/env bash
set -e

source /home/devuser/venv/bin/activate

echo "Launching PX4 SITL (AirSim-ready)..."

cd /home/devuser/PX4-Autopilot

# This is now FAST (already compiled)
make px4_sitl_default none_iris

exec bash
