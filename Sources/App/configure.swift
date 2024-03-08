import Vapor
import Fluent
import FluentMongoDriver
import FluentPostgresDriver

public func configure(_ app: Application) async throws {
    let databaseName: String
    let databasePort: Int

    if (app.environment == .testing) {
      databaseName = testDatabaseName
      databasePort = testDatabasePort
    } else {
      databaseName = productionDatabaseName
      databasePort = productionDatabasePort
    }

    app.databases.use(.postgres(
      hostname: Environment.get("DATABASE_HOST")
        ?? "localhost",
      port: databasePort,
      username: Environment.get("DATABASE_USERNAME")
        ?? "root",
      password: Environment.get("DATABASE_PASSWORD")
        ?? "root",
      database: Environment.get("DATABASE_NAME")
        ?? databaseName
    ), as: .psql)

    // to access in docker docker exec -it docker-container-name mongosh
    // try app.databases.use(.mongo(connectionString: "mongodb://localhost:10808/products-db"), as: .mongo)

    // Migrations
    app.migrations.add(CreateDBSchema())
    app.migrations.add(AddInitialRecipes())


    // register routes
    try routes(app)
}
