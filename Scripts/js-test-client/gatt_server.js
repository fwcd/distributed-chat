// Acts as a GATT server/peripheral for
// exchanging chat messages with real iOS nodes.

// NOTE: Accepting service discovery requests seems
//       to have some issues with bluetoothd currently,
//       see https://github.com/noble/bleno/issues/24.
//       The workaround (for now) is to manually disable
//       bluetoothd via systemd, then re-enable it directly:
//
//           sudo systemctl stop bluetooth
//           sudo hciconfig hci0 up
//
//       Once you are done, remember to restart bluetoothd:
//
//           sudo systemctl start bluetooth

const bleno = require('@abandonware/bleno'); // Peripheral/GATT server
const {
  serviceUUID,
  inboxCharacteristicUUID,
  userIDCharacteristicUUID,
  userNameCharacteristicUUID,
  myID,
  myName
} = require('./gatt_constants');

function handle(error) {
  if (error) {
    console.log(error);
    return false;
  }
  return true;
}

// GATT server

bleno.on('advertisingStart', err => {
  if (!handle(err)) return;

  console.log('Setting services...');
  bleno.setServices([
    new bleno.PrimaryService({
      uuid: serviceUUID,
      characteristics: [
        new bleno.Characteristic({
          uuid: inboxCharacteristicUUID,
          properties: ['write'],
          secure: [],
          descriptors: []
        }),
        new bleno.Characteristic({
          uuid: userNameCharacteristicUUID,
          properties: ['read'],
          secure: [],
          value: Buffer.from(myName, 'utf-8'),
          descriptors: []
        }),
        new bleno.Characteristic({
          uuid: userIDCharacteristicUUID,
          properties: ['read'],
          secure: [],
          value: Buffer.from(myID, 'utf-8'),
          descriptors: []
        })
      ]
    })
  ]);
});

bleno.on('stateChange', state => {
  if (state === 'poweredOn') {
    console.log('Starting to advertise...');
    bleno.startAdvertising(myName, [serviceUUID], err => handle(err));
  }
});
