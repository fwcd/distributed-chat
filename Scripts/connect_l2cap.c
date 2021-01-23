// This script connects via Bluetooth LE to a specified
// address/PSM and sends a simple 'hello' message.
// Currently only tested on Linux
// (you may need to apt-get install libbluetooth-dev).

#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <bluetooth/bluetooth.h>
#include <bluetooth/l2cap.h>

int main(int argc, char **argv) {
    if (argc < 4) {
        printf("Usage: %s [bluetooth address] [1 if public, 2 if random] [psm]\n", argv[0]);
        return -1;
    }

    struct sockaddr_l2 addr = { 0 };
    addr.l2_family = AF_BLUETOOTH;
    addr.l2_bdaddr_type = atoi(argv[2]); // BDADDR_LE_PUBLIC = 1, BDADDR_LE_RANDOM = 2
    addr.l2_psm = atoi(argv[3]);
    str2ba(argv[1], &addr.l2_bdaddr);

    int s = socket(AF_BLUETOOTH, SOCK_SEQPACKET, BTPROTO_L2CAP);

    printf("Connecting to L2CAP target via Bluetooth LE...\n");
    if (!connect(s, (struct sockaddr *) &addr, sizeof(addr))) {
        printf("Failed to connect!");
        return -1;
    }

    return 0;
}
