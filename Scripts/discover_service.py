# This is a small script that acts as a GATT central/client
# for discovering real nodes (i.e. devices running the iOS app).
# 
# Once our DistributedChat service has been discovered, it
# prompts for a string to write to our 'message inbox'
# characteristic.
#
# To use, run 'pip3 install bluepy'

# NOTE: This script MUST run as root!

from bluepy.btle import Scanner, Peripheral
import socket

from gatt_constants import SERVICE_UUID, CHARACTERISTIC_UUID

scanner = Scanner()

while True:
    print('Scanning for devices...')
    devices = scanner.scan(10.0)
    for dev in devices:
        print(f'Device {dev.addr} (RSSI: {dev.rssi})')
        for (adtype, desc, value) in dev.getScanData():
            print(f'Adtype: {adtype}, desc: {desc}, value: {value}')
            if adtype == 7 and value == SERVICE_UUID:
                print('  >> Found the DistributedChat service, finding characteristics...')
                peripheral = Peripheral(dev.addr, dev.addrType, dev.iface)
                characteristics = peripheral.getCharacteristics(uuid=CHARACTERISTIC_UUID)
                if characteristics:
                    s = input(f'  >> Enter a string to write to characteristic: ').encode('utf8')
                    c = characteristics[0]
                    c.write(s, withResponse=True)
                    print('  >> Wrote successfully!')
                else:
                    print('  >> Could not find our characteristic. :(')
                peripheral.disconnect()
