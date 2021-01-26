// Acts as a GATT server for
// exchanging chat messages with real iOS nodes.

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
  }
}

// GATT server

bleno.setServices([
  {
    uuid: serviceUUID,
    characteristics: [
      {
        uuid: inboxCharacteristicUUID,
        properties: ['write'],
        secure: [],
        descriptors: []
      },
      {
        uuid: userNameCharacteristicUUID,
        properties: ['read'],
        secure: [],
        value: Buffer.from(myName, 'utf-8'),
        descriptors: []
      },
      {
        uuid: userIDCharacteristicUUID,
        properties: ['read'],
        secure: [],
        value: Buffer.from(myID, 'utf-8'),
        descriptors: []
      }
    ]
  }
]);

bleno.on('stateChange', state => {
  if (state === 'poweredOn') {
    console.log('Starting to advertise...');
    bleno.startAdvertising(myName, [serviceUUID], err => handle(err));
  }
});
