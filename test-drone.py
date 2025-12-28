import asyncio
from mavsdk import System

async def connect_drone(port):
    drone = System()
    print(f"Connecting to drone on port {port}...")
    await drone.connect(system_address=f"udp://: {port}")

    async for state in drone.core.connection_state():
        if state.is_connected:
            print(f"✅ Drone on port {port} connected!")
            break

async def main():
    ports = [14540, 14541, 14542]
    await asyncio.gather(*[connect_drone(port) for port in ports])

if __name__ == "__main__":
    asyncio.run(main())
