import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", [
            "title": "Distributed Chat Simulation Server"
        ])
    }

    let handler = MessagingHandler()
    app.webSocket("messaging") { req, ws in
        handler.connect(ws)
    }
}
