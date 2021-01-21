# Distributed Chat

[![Distributed Chat Build](https://github.com/fwcd/distributed-chat/workflows/Distributed%20Chat/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3ADistributed%20Chat)
[![App Build](https://github.com/fwcd/distributed-chat/workflows/App/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3AApp)
[![CLI Build](https://github.com/fwcd/distributed-chat/workflows/CLI/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3ACLI)
[![Simulation Server Build](https://github.com/fwcd/distributed-chat/workflows/Simulation%20Server/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3ASimulation%20Server)

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
