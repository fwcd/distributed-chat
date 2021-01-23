# This is a small script that acts as a GATT central/client
# for discovering real nodes (i.e. devices running the iOS app).
# 
# Those should be advertising a GATT service with a PSM on which
# they expose an L2CAP channel.
#
# To use, run 'pip3 install bluepy'

# NOTE: This script MUST run as root! Also, it can currently
#       only discover the PSM of a node, not open the L2CAP
#       channel to it.

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
                print('  >> Found the DistributedChat service, reading characteristic...')
                peripheral = Peripheral(dev.addr, dev.addrType, dev.iface)
                characteristics = peripheral.getCharacteristics(uuid=CHARACTERISTIC_UUID)
                if characteristics:
                    # The PSM is stored in big-endian form
                    psm = int.from_bytes(characteristics[0].read(), 'big')
                    print(f'  >> Read PSM {psm} from our DistributedChat-specific GATT characteristic')

                    # TODO: Python sockets do not support Bluetooth LE, see
                    #       https://bugs.python.org/issue25056

                    # s = socket.socket(socket.AF_BLUETOOTH, socket.SOCK_SEQPACKET, socket.BTPROTO_L2CAP)
                    # print(f'  >> Connecting to {dev.addr} with PSM {psm} via L2CAP...')
                    # s.connect((dev.addr, psm))
                    # print('  >> Connected, attempting to send a string...')
                    # s.send('Hello world!'.encode('utf8'))
                peripheral.disconnect()
