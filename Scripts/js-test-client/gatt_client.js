// Acts as a GATT client/central for
// exchanging chat messages with real iOS nodes.

const noble = require('@abandonware/noble'); // Central/GATT client
const readline = require('readline');
const { v4: uuid4 } = require('uuid');
const {
  serviceUUID,
  inboxCharacteristicUUID,
  userIDCharacteristicUUID,
  userNameCharacteristicUUID,
  myID,
  myName
} = require('./gatt_constants');

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

function question(query) {
  return new Promise(resolve => {
    rl.question(query, answer => {
      resolve(answer);
    });
  });
}

// GATT client

noble.on('discover', async peripheral => {
  console.log(`Found peripheral ${peripheral}`);
  await noble.stopScanningAsync();
  await peripheral.connectAsync();

  const { characteristics } = await peripheral.discoverSomeServicesAndCharacteristicsAsync([serviceUUID], [inboxCharacteristicUUID, userNameCharacteristicUUID, userIDCharacteristicUUID]);
  const inboxChar = characteristics.find(c => c.uuid === inboxCharacteristicUUID);
  const userNameChar = characteristics.find(c => c.uuid === userNameCharacteristicUUID);
  const userIDChar = characteristics.find(c => c.uuid === userIDCharacteristicUUID);

  if (inboxChar && userNameChar && userIDChar) {
    console.log(`Discovered our characteristics!`);
    const userName = (await userNameChar.readAsync()).toString('utf-8');
    const userID = (await userIDChar.readAsync()).toString('utf-8');
    let logicalClock = 0;

    while (true) {
      const content = await question('Please enter a message: ');
      const timestamp = Date.now() / 1000.0;
      const json = JSON.stringify({
        id: uuid4(),
        timestamp: timestamp,
        sourceUserId: myID,
        visitedUsers: [],
        logicalClock: logicalClock++,
        addedChatMessages: [
          {
            id: uuid4(),
            timestamp: timestamp,
            author: {
              id: myID,
              name: myName
            },
            content: {
              type: 'text',
              data: content
            }
          }
        ]
      }) + '\n';
      await inboxChar.writeAsync(Buffer.from(json, 'utf-8'), false);
    }
  }
});

noble.on('stateChange', async state => {
  if (state === 'poweredOn') {
    console.log('Scanning for devices...');
    await noble.startScanningAsync([serviceUUID], false);
  }
});
