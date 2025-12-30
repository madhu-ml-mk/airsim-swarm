#!/usr/bin/env bash
set -e

# Activate Python venv
if [ -f /home/devuser/venv/bin/activate ]; then
    source /home/devuser/venv/bin/activate
fi

echo "Container started."

# If PX4_AUTOSTART=1 → start PX4
if [ "$PX4_AUTOSTART" = "1" ]; then
    echo "Starting PX4 SITL (AirSim mode)..."
    cd /home/devuser/PX4-Autopilot
    # Match AirSim settings.json (UDP port)
    make px4_sitl_default none_iris
else
    # If PX4_AUTOSTART is not 1, drop to bash for debugging
    exec bash
fi
