#!/usr/bin/env bash
set -e

# -------------------------------
# Activate Python virtual environment
# -------------------------------
VENV_PATH="/home/devuser/venv"
if [ -f "$VENV_PATH/bin/activate" ]; then
    source "$VENV_PATH/bin/activate"
else
    echo "ERROR: Python virtual environment not found at $VENV_PATH"
    exit 1
fi

# -------------------------------
# Ensure PX4 Python dependencies
# -------------------------------
REQUIRED_PKGS=(pyserial empy toml kconfiglib pandas numpy pyulog)
for pkg in "${REQUIRED_PKGS[@]}"; do
    pip show "$pkg" > /dev/null 2>&1 || pip install "$pkg"
done

# Optionally, install all PX4 venv requirements
PX4_REQS="/home/devuser/PX4-Autopilot/Tools/setup/requirements.txt"
if [ -f "$PX4_REQS" ]; then
    pip install -r "$PX4_REQS"
fi

# -------------------------------
# Start PX4 SITL (AirSim mode)
# -------------------------------
echo "Starting PX4 SITL (AirSim mode)..."
cd /home/devuser/PX4-Autopilot

# Build & run SITL with the 'none_iris' AirSim target
make px4_sitl_default none_iris

exec bash
