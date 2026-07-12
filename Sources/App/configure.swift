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
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: databasePort,
        username: Environment.get("DATABASE_USERNAME") ?? "root",
        password: Environment.get("DATABASE_PASSWORD") ?? "root",
        database: Environment.get("DATABASE_NAME") ?? databaseName
    ), as: .psql)

    // Migrations
    app.migrations.add(CreateDBSchema())
    app.migrations.add(AddInitialRecipes())
    app.migrations.add(ChangeQuantityToFloat())

    try await app.autoMigrate()

    try routes(app)
}
