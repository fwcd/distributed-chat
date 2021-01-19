# Distributed Chat

A cross-platform distributed chat application that uses mesh networks to transmit messages.

![Logo](logo.svg)

The project consists of the following components:

* `DistributedChat`: The abstract application, platform-independent, transport-independent (uses interface for broadcasting/receiving messages)
* `DistributedChatApp`: The iOS implementation, uses Bluetooth as transport, does **not** require a server
* `DistributedChatCLI`: The CLI implementation, uses HTTP as transport with the simulation server, mainly for testing
* `DistributedChatSimulationServer`: The companion server for the CLI, relays messages between connected CLI nodes, provides web-interface for configuring links between nodes

The dependency graph between these packages looks like this:

```
                           +-----------------+
                           | DistributedChat |
                           +-----------------+
                                    ^
           +------------------------+-----------------------------+
           |                        |                             |
+--------------------+ +--------------------+ +---------------------------------+
| DistributedChatApp | | DistributedChatCLI | | DistributedChatSimulationServer |
+--------------------+ +--------------------+ +---------------------------------+

 \__________________/   \______________________________________________________/
       iOS only                     cross-platform, for testing
```
