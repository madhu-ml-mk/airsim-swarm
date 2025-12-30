#!/usr/bin/env bash
set -e

# Activate Python venv
if [ -f /home/devuser/venv/bin/activate ]; then
    source /home/devuser/venv/bin/activate
fi

echo "Container started."

cd /home/devuser/PX4-Autopilot

# Start PX4 if requested
if [ "$PX4_AUTOSTART" = "1" ]; then
    echo "Starting PX4 SITL (AirSim mode)..."
    make px4_sitl_default none_iris &
fi

# Always drop into bash (keeps container alive)
exec bash
