// Acts as a GATT server and client for
// exchanging chat messages with real iOS nodes.
// 
// To use, run 'apt-get install bluetooth bluez libbluetooth-dev libudev-dev'.
// (if you are using Debian/Ubuntu), then 'npm install -g noble bleno'.

const noble = require('noble'); // Central/GATT client
const bleno = require('bleno'); // Peripheral/GATT server
const readline = require('readline');
const { v4: uuid4 } = require('uuid');

const serviceUUID = '59553ceb2ffa40188a6c453a5292044d';
const inboxCharacteristicUUID = '440a594c3cc2494aa08abe8dd23549ff';
const userNameCharacteristicUUID = 'b2234f402c0b401b8145c612b9a7bae1';
const userIDCharacteristicUUID = '13a4d26e0a754fde93404974e3da3100';

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

noble.on('discover', peripheral => {
  console.log(`Found peripheral ${peripheral}`);
  noble.stopScanning();
  peripheral.connect(err => {
    if (err) {
      console.log(err);
      return;
    }

    peripheral.discoverServices([serviceUUID], (err, services) => {
      if (err) {
        console.log(err);
        return;
      }

      if (services) {
        console.log(`Discovered DistributedChat service!`);
        const service = services[0];

        service.discoverCharacteristics([
          inboxCharacteristicUUID,
          userNameCharacteristicUUID,
          userIDCharacteristicUUID
        ], (err, chars) => {
          if (err) {
            console.log(err);
            return;
          }

          const inboxChar = chars.find(c => c.uuid === inboxCharacteristicUUID);
          const userNameChar = chars.find(c => c.uuid === userNameCharacteristicUUID);
          const userIDChar = chars.find(c => c.uuid === userIDCharacteristicUUID);
          
          userNameChar.read((err, data) => {
            if (err) {
              console.log(err);
              return;
            }
            const userName = data.toString('utf-8');

            userIDChar.read((err, data) => {
              if (err) {
                console.log(err);
                return;
              }
              const userID = data.toString('utf-8');

              console.log(`Remote user has name ${userName} and ID ${userID}`);

              rl.question('Please enter a name: ', myName => {
                const myID = uuid4();

                function chatREPL() {
                  rl.question('Please enter a message: ', content => {
                    console.log(`Writing '${content}' to characteristic...`)
                    // TODO: Noble does not seem to support long characteristics,
                    //       see https://github.com/noble/noble/issues/13
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
                    }), 'utf-8'), false, err => {
                      if (err) {
                        console.log(err);
                        return;
                      }
                      chatREPL();
                    });
                  });
                }

                chatREPL();
              });
            });
          });
        });
      } else {
        peripheral.disconnect();
      }
    });
  });
});

noble.on('stateChange', state => {
  if (state === 'poweredOn') {
    console.log('Scanning for devices...');
    noble.startScanning([serviceUUID], false, err => console.log(err));
  } else {
    console.log('Stopping scan...');
    noble.stopScanning();
  }
});
