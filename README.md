# Distributed Chat

[![Distributed Chat Build](https://github.com/fwcd/distributed-chat/workflows/Distributed%20Chat/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3A"Distributed+Chat")
[![App Build](https://github.com/fwcd/distributed-chat/workflows/App/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3AApp)
[![CLI Build](https://github.com/fwcd/distributed-chat/workflows/CLI/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3ACLI)
[![Simulation Protocol Build](https://github.com/fwcd/distributed-chat/workflows/Simulation%20Protocol/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3A"Simulation+Protocol")
[![Simulation Server Build](https://github.com/fwcd/distributed-chat/workflows/Simulation%20Server/badge.svg)](https://github.com/fwcd/distributed-chat/actions?query=workflow%3A"Simulation+Server")

A cross-platform distributed chat application that uses mesh networks to transmit messages.

![Logo](logo.svg)

## Components

The project consists of the following components:

* `DistributedChat`: The abstract application, platform-independent, transport-independent (uses interface for broadcasting/receiving messages)
* `DistributedChatApp`: The iOS implementation, uses Bluetooth as transport, does **not** require a server
* `DistributedChatCLI`: The CLI implementation, uses HTTP/WebSockets as transport with the simulation server
* `DistributedChatSimulationProtocol`: The high-level JSON-based protocol used between CLI and simulation server
* `DistributedChatSimulationServer`: The companion server for the CLI, relays messages between connected CLI nodes, provides web-interface for configuring links between nodes

The dependency graph between these packages looks like this:

```
             +-----------------+  +-----------------------------------+
             | DistributedChat |  | DistributedChatSimulationProtocol |
             +-----------------+  +-----------------------------------+
                      ^                      ^
                      |                      |
           +----------+-------------+   +---------+
           |                        |   |         |
+--------------------+ +--------------------+ +---------------------------------+
| DistributedChatApp | | DistributedChatCLI | | DistributedChatSimulationServer |
+--------------------+ +--------------------+ +---------------------------------+

 \__________________/   \______________________________________________________/
       iOS only                     cross-platform, for testing
```

## Build & Run

### Cross-platform

To build the `DistributedChat`, `DistributedChatCLI` or `DistributedSimulationServer` packages, make sure to have the following installed:

* Swift 5.3+

Then navigate into the package subdirectory and run

```
swift build
```

or

```
swift run
```

if the package is executable.

### macOS

To build the `DistributedChatApp`, make sure to have the following installed:

* Xcode 12+
* Swift 5.3 (should be included with Xcode)
* optionally an iOS 14 device

The open the `DistributedChatApp` subdirectory in Xcode and build/run the project.
