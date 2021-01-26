// Acts as a GATT server and client for
// exchanging chat messages with real iOS nodes.
// 
// To use, run 'apt-get install bluetooth bluez libbluetooth-dev libudev-dev'.
// (if you are using Debian/Ubuntu), then 'npm install -g noble bleno'.

const noble = require('noble'); // Central/GATT client
const bleno = require('bleno'); // Peripheral/GATT server
const readline = require('readline');
const { v4: uuid4 } = require('uuid');
const { rawListeners } = require('process');

const serviceUUID = '59553ceb-2ffa-4018-8a6c-453a5292044d';
const inboxCharacteristicUUID = '440a594c-3cc2-494a-a08a-be8dd23549ff';
const userNameCharacteristicUUID = 'b2234f40-2c0b-401b-8145-c612b9a7bae1';
const userIDCharacteristicUUID = '13a4d26e-0a75-4fde-9340-4974e3da3100';

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

noble.on('discover', peripheral => {
  console.log(`Found peripheral ${peripheral}`);
  // peripheral.connect();
  peripheral.discoverServices([serviceUUID], (err, services) => {
    if (err) console.log(err);

    if (services) {
      console.log(`Discovered DistributedChat service!`);
      const service = services[0];

      service.discoverCharacteristics([
        inboxCharacteristicUUID,
        userNameCharacteristicUUID,
        userIDCharacteristicUUID
      ], (err, chars) => {
        if (err) console.log(err);

        const inboxChar = chars.find(c => c.uuid === inboxCharacteristicUUID);
        const userNameChar = chars.find(c => c.uuid === userNameCharacteristicUUID);
        const userIDChar = chars.find(c => c.uuid === userIDCharacteristicUUID);
        
        userNameChar.read((err, data) => {
          if (err) console.log(err);
          const userName = data.toString('utf-8');

          userIDChar.read((err, data) => {
            if (err) console.log(err);
            const userID = data.toString('utf-8');

            console.log(`Remote user has name ${userName} and ID ${userID}`);

            rl.question('Please enter a name: ', myName => {
              const myID = uuid4();

              userNameChar.write(Buffer.from(myName, 'utf-8'));
              userIDChar.write(Buffer.from(myID, 'utf-8'));

              function chatREPL() {
                rl.question('Please enter a message: ', content => {
                  inboxChar.write(Buffer.from(JSON.stringify({
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
                  }), 'utf-8'));
                });
              }

              chatREPL();
            });
          });
        });
      });
    }
  });
});

console.log('Scanning for devices...');
noble.startScanning([serviceUUID]);
