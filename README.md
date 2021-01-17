# Distributed Chat

A cross-platform distributed chat application that is comprised of the following components:

* `DistributedChat`: The core application, platform-independent, with interfaces for broadcasting/receiving messages
* `DistributedChatApp`: The iOS implementation, uses Bluetooth as transport
* `DistributedChatLocalCLI`: The CLI implementation, uses a local HTTP server as transport, mainly for testing
* `DistributedChatLocalServer`: The companion server for the CLI, relays messages between connected CLI nodes
