import Foundation
import Fluent
import Model

struct CreateDBSchema: AsyncMigration {

    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeEntry.schema)
                    .id()
                    .field("name", .string)
                    .field("description", .string)
                    .field("shortDescription", .string)
                    .create()

        try await database.schema(DBRecipeProductEntry.schema)
                    .id()
                    .field("count", .int64)
                    .field("quantityMeasure", .int64)
                    .field("productType", .string)
                    .field("recipe_id", .uuid, .required, .references(DBRecipeEntry.schema, "id", onDelete: .cascade))
                    .create()
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeProductEntry.schema).delete()
        try await database.schema(DBRecipeEntry.schema).delete()
    }
}
