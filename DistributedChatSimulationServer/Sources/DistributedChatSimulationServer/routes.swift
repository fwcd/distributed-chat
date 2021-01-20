import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return req.view.render("index", [
            "title": "Distributed Chat Simulation Server"
        ])
    }

    // app.get("hello") { req -> String in
    //     return "Hello, world!"
    // }
}
