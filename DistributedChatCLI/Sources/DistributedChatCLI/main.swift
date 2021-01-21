import LineNoise

let ln = LineNoise()

while let input = try? ln.getLine(prompt: "> ") {
    ln.addHistory(input)
    print()

    // TODO: Actually handle input
    print(input)
}

print()
