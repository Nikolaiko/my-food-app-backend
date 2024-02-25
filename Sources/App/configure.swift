import Vapor
import Fluent
import FluentMongoDriver
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // register database
    app.databases.use(.postgres(hostname: "localhost", username: "root", password: "root", database: "products"), as: .psql)


    // to access in docker docker exec -it docker-container-name mongosh
    // try app.databases.use(.mongo(connectionString: "mongodb://localhost:10808/products-db"), as: .mongo)

    // Migrations
    app.migrations.add(CreateDBSchema())
    app.migrations.add(AddInitialRecipes())


    // register routes
    try routes(app)
}
