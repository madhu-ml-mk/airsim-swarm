import time
from pymavlink import mavutil

# ---------------- CONFIG ----------------
DRONES = {
    "drone_1": {"port": 14550},
    # Add more when ready:
    # "drone_2": {"port": 14560},
}

POS_ACCURACY_THRESHOLD = 500.0  # meters (spoof signature)
CHECK_INTERVAL = 1.0            # seconds
# ----------------------------------------


class Drone:
    def __init__(self, name, port):
        self.name = name
        self.port = port
        self.mav = None
        self.spoofed = False

    def connect(self):
        print(f"🔗 Connecting to {self.name} on UDP {self.port}...")
        self.mav = mavutil.mavlink_connection(
            f"udp:0.0.0.0:{self.port}",
            source_system=255
        )
        self.mav.wait_heartbeat(timeout=10)
        print(f"✅ {self.name} connected (SYSID={self.mav.target_system})")

    def disable_gps(self):
        print(f"🛡️ {self.name}: DISABLING GPS AIDING")
        self.mav.mav.param_set_send(
            self.mav.target_system,
            self.mav.target_component,
            b"EKF2_GPS_CTRL",
            0,
            mavutil.mavlink.MAV_PARAM_TYPE_INT32
        )
        self.mav.mav.param_set_send(
            self.mav.target_system,
            self.mav.target_component,
            b"EKF2_AID_MASK",
            1,  # inertial only
            mavutil.mavlink.MAV_PARAM_TYPE_INT32
        )

    def monitor(self):
        msg = self.mav.recv_match(type="ESTIMATOR_STATUS", blocking=False)
        if not msg:
            return

        pos_acc = msg.pos_horiz_accuracy

        print(
            f"{self.name}: "
            f"pos_accuracy={pos_acc:.1f} m"
        )

        if pos_acc > POS_ACCURACY_THRESHOLD and not self.spoofed:
            print(f"🚨 SPOOF DETECTED on {self.name}")
            self.disable_gps()
            self.spoofed = True


def main():
    drones = []

    for name, cfg in DRONES.items():
        d = Drone(name, cfg["port"])
        d.connect()
        drones.append(d)

    print("\n📡 Swarm GPS Guard ACTIVE\n")

    while True:
        for d in drones:
            d.monitor()
        time.sleep(CHECK_INTERVAL)


if __name__ == "__main__":
    main()
