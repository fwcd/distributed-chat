# This is a small script that acts as a GATT central/client
# for discovering real nodes (i.e. devices running the iOS app).
# 
# Those should be advertising a GATT service with a PSM on which
# they expose an L2CAP channel.

# NOTE: This script MUST run as root!

from bluepy.btle import Scanner, Peripheral

from gatt_constants import SERVICE_UUID, CHARACTERISTIC_UUID

scanner = Scanner()

while True:
    print('Scanning for devices...')
    devices = scanner.scan(10.0)
    for dev in devices:
        print(f'Device {dev} (RSSI: {dev.rssi})')
        for (adtype, desc, value) in dev.getScanData():
            print(f'Adtype: {adtype}, desc: {desc}, value: {value}')
            if adtype == 7 and value == SERVICE_UUID:
                print(' >> Found the DistributedChat service, reading characteristic...')
                peripheral = Peripheral(dev.addr, dev.addrType, dev.iface)
                characteristics = peripheral.getCharacteristics(uuid=CHARACTERISTIC_UUID)
                if characteristics:
                    psm = characteristics[0].read()
                    print(f'  >> Read PSM {psm} from our DistributedChat-specific GATT characteristic!')
                peripheral.disconnect()
