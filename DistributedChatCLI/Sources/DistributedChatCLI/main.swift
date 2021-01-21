import ArgumentParser
import LineNoise

struct DistributedChatCLI: ParsableCommand {
    @Argument(help: "The messaging WebSocket URL of the simulation server to connect to")
    var messagingURL: String = "ws://localhost:8080/messaging"

    mutating func run() throws {
        let ln = LineNoise()

        while let input = try? ln.getLine(prompt: "> ") {
            ln.addHistory(input)
            print()

            // TODO: Actually handle input
            print(input)
        }

        print()
    }
}

DistributedChatCLI.main()
