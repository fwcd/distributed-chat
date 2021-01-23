# This is a small script that acts as a GATT central/client
# for discovering real nodes (i.e. devices running the iOS app).
# 
# Those should be advertising a GATT service with a PSM on which
# they expose an L2CAP channel.
#
# To use, run 'apt-get install libbluetooth-dev', then 'pip3 install pybluez gattlib'

# NOTE: Requires Linux currently and MUST run as root

from bluetooth.ble import DiscoveryService

from gatt_constants import SERVICE_UUID, CHARACTERISTIC_UUID

service = DiscoveryService()
devices = service.discover(2)

for address, name in devices.items():
    print(f'Address: {address}, name: {name}')

# TODO: Discover GATT services
