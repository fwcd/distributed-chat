# This is a small script that acts as test client for
# sending chat messages to real iOS nodes running the
# DistributedChat service.
# 
# Once our DistributedChat service has been discovered, it
# prompts for a string to write to our 'message inbox'
# characteristic.
#
# Note that the script only acts as a GATT central and
# NOT a peripheral, i.e. it does not expose such a service
# with a 'message inbox' itself (thereby making it only
# possible to send chat messages, not receive).
#
# To use, run 'pip3 install bluepy', then 'python3 test_client.py'.
# NOTE: This script MUST run as root!

import json
import time
from bluepy.btle import Scanner, Peripheral
from uuid import uuid4
from gatt_constants import SERVICE_UUID, CHARACTERISTIC_UUID

scanner = Scanner()

def main():
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
                    my_name = 'Test Client'
                    my_id = str(uuid4())
                    while True:
                        content = input(f'  >> Enter a chat message to send: ')
                        # See ChatProtocol.Message in DistributedChat package for a
                        # description of the JSON message structure.
                        s = json.dumps({
                            'visitedUsers': [],
                            'addedChatMessages': [
                                {
                                    'id': str(uuid4()),
                                    'timestamp': time.time(),
                                    'author': {
                                        'id': my_id,
                                        'name': my_name
                                    },
                                    'content': content
                                }
                            ]
                        }).encode('utf8')
                        c = characteristics[0]
                        c.write(s, withResponse=True)
                        print('  >> Wrote successfully!')
                    else:
                        print('  >> Could not find our characteristic. :(')
                peripheral.disconnect()
