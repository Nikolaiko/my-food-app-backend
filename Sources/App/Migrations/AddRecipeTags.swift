import Foundation
import Fluent
import FluentSQL

struct AddRecipeTags: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeEntry.schema)
            .field("tags", .array(of: .int64), .required, .sql(.default("{}")))
            .update()
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeEntry.schema)
            .deleteField("tags")
            .update()
    }
}
