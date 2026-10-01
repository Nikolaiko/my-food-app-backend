import Foundation
import Fluent

struct AddRecipeNutrition: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeEntry.schema)
            .field("proteins", .double)
            .field("fats", .double)
            .field("carbohydrates", .double)
            .field("calories", .double)
            .update()
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeEntry.schema)
            .deleteField("proteins")
            .deleteField("fats")
            .deleteField("carbohydrates")
            .deleteField("calories")
            .update()
    }
}
