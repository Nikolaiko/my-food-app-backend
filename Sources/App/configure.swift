import Vapor
import Fluent
import FluentMongoDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))


    //to access in docker docker exec -it docker-container-name mongosh
    // register database
    do {
        try app.databases.use(.mongo(connectionString: "mongodb://root:root@localhost:27017/products-db"), as: .mongo)
    } catch {
        print("Error : \(error)")
    }


    // register routes
    try routes(app)
}
