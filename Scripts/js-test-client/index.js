// Acts as a GATT server and client for
// exchanging chat messages with real iOS nodes.
// 
// To use, run 'apt-get install bluetooth bluez libbluetooth-dev libudev-dev'.
// (if you are using Debian/Ubuntu), then 'npm install -g noble bleno'.

const noble = require('@abandonware/noble'); // Central/GATT client
const bleno = require('@abandonware/bleno'); // Peripheral/GATT server
const readline = require('readline');
const { v4: uuid4 } = require('uuid');

const serviceUUID = '59553ceb2ffa40188a6c453a5292044d';
const inboxCharacteristicUUID = '440a594c3cc2494aa08abe8dd23549ff';
const userNameCharacteristicUUID = 'b2234f402c0b401b8145c612b9a7bae1';
const userIDCharacteristicUUID = '13a4d26e0a754fde93404974e3da3100';

const chunkLength = 19; // for writing to BLE characteristics
const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

function question(query) {
  return new Promise(resolve => {
    rl.question(query, answer => {
      resolve(answer);
    });
  });
}

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
    const myName = await question('Please enter a name: ');
    const myID = uuid4();

    while (true) {
      const content = await question('Please enter a message: ');
      const json = JSON.stringify({
        visitedUsers: [],
        addedChatMessages: [
          {
            id: uuid4(),
            timestamp: Date.now() / 1000.0,
            author: {
              id: myID,
              name: myName
            },
            content: content
          }
        ]
      });
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
