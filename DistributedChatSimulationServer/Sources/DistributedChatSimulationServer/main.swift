import Vapor

let app = try Application(.detect())

defer { app.shutdown() }

app.get { req in
    return "Hello World!"
}

try app.run()
