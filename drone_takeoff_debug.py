import asyncio
from mavsdk import System

async def run():
    drone = System(mavsdk_server_address="localhost", port=14540)
    await drone.connect()

    print("[Drone] Connecting...")
    async for state in drone.core.connection_state():
        if state.is_connected:
            print("[Drone] Connected ✅")
            break

    print("[Drone] Arming...")
    await drone.action.arm()

    print("[Drone] Taking off...")
    await drone.action.takeoff()

    await asyncio.sleep(10)

    print("[Drone] Landing...")
    await drone.action.land()

    await asyncio.sleep(5)
    print("[Drone] Done.")

if __name__ == "__main__":
    asyncio.run(run())
