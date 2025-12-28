import asyncio
from mavsdk import System

# Drone list: system addresses (UDP endpoints)
drone_system_addresses = ["udp://localhost:4560"]

async def connect_and_takeoff(system_address):
    drone = System()
    print(f"[{system_address}] Connecting...")
    await drone.connect(system_address=system_address)

    async for state in drone.core.connection_state():
        if state.is_connected:
            print(f"[{system_address}] Connected ✅")
            break

    print(f"[{system_address}] Arming...")
    await drone.action.arm()

    print(f"[{system_address}] Taking off...")
    await drone.action.takeoff()

    await asyncio.sleep(8)
    return drone

async def main():
    drones = await asyncio.gather(*[connect_and_takeoff(addr) for addr in drone_system_addresses])
    print("✅ All drones took off")

    await asyncio.sleep(10)

    for i, drone in enumerate(drones):
        print(f"[{drone_system_addresses[i]}] Landing...")
        await drone.action.land()

    print("✅ All drones landed")

if __name__ == "__main__":
    asyncio.run(main())
