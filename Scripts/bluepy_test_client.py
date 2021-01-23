# This is a small script that acts as a GATT central/client
# for discovering real nodes (i.e. devices running the iOS app).
# 
# Those should be advertising a GATT service with a PSM on which
# they expose an L2CAP channel.
#
# Note that this script MUST run as root.

from bluepy.btle import Scanner

scanner = Scanner()

while True:
    print('Scanning for devices...')
    devices = scanner.scan(10.0)
    for dev in devices:
        print(f'Device {dev} (RSSI: {dev.rssi})')
        for (adtype, desc, value) in dev.getScanData():
            print(f'Adtype: {adtype}, desc: {desc}, value: {value}')
