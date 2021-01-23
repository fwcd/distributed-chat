# This is a small script that acts as a GATT central/client
# for discovering real nodes (i.e. devices running the iOS app).
# 
# Those should be advertising a GATT service with a PSM on which
# they expose an L2CAP channel.

# NOTE: Please use the bluepy_test_client.py script for now,
#       see TODO note below!

import asyncio
from bleak import BleakScanner, BleakClient

from gatt_constants import SERVICE_UUID, CHARACTERISTIC_UUID

async def run():
    print('Discovering devices...')
    while True:
        devices = await BleakScanner.discover()
        for d in devices:
            print(f'Discovered {d.address}, {d.name} (RSSI: {d.rssi})')
            services = d.metadata['uuids']
            print(f"  >> Offers services {services}")
            if SERVICE_UUID in services:
                print('  >> Found our DistributedChat service, connecting...')
                async with BleakClient(d.address) as client:
                    # TODO: This currently attempts pairing, which is neither desired
                    #       nor required as it presents a pairing modal on the node.
                    psm = await client.read_gatt_char(CHARACTERISTIC_UUID)
                    print(f'  >> Advertised PSM is {psm}')

loop = asyncio.get_event_loop()
loop.run_until_complete(run())
