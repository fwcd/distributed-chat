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

## Building and Running

First, make sure to have Swift 5.3+ or newer installed. Recent versions for Ubuntu and macOS can be found [here](https://swift.org/download/).

### Simulation Server

To run the simulation server, navigate into the directory `DistributedChatSimulationServer` and execute:

```
swift run
```

The web interface should now be accessible at `http://localhost:8080`.

### CLI

To start a single instance of the CLI, make sure that the simulation server is running, navigate into `DistributedChatCLI` and execute:

```
swift run DistributedChatCLI --name Alice
```

You can substitute any name for Alice. Once the CLI has started, the chosen name should show up as a node in the simulation server's web interface.

### iOS app

Building and running the iOS app is only possible on macOS, so make sure to have the following available:

* Xcode 12+
* Swift 5.3 (should be included with Xcode)
* optionally an iOS 14 device

The open the `DistributedChatApp` subdirectory in Xcode and build/run the project.
