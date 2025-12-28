#!usr/bin/env bash
set -e

# Activate Python venv
source /home/devuser/venv/bin/activate

echo "Starting PX4 SITL (AirSim mode)..."

# Move to PX4 folder
cd /home/devuser/PX4-Autopilot

# Start PX4 SITL in background
make px4_sitl_default none_iris &

PX4_PID=$!

# Wait a few seconds to ensure PX4 SITL is up
sleep 5

# Start AirSim (headless by default)
echo "Starting AirSim..."
# If you have Unreal/compiled AirSim binary, start it here
# Example placeholder for AirSim Python API simulation
# python3 /home/devuser/airsim-swarm/AirSim/PythonClient/multirotor/hello_drone.py &

# Optional: wait for PX4 to finish (usually never)
wait $PX4_PID

# Keep container alive with dev shell
exec bash
