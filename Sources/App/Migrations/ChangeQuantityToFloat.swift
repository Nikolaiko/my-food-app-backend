import Foundation
import Fluent
import Model

struct ChangeQuantityToFloat: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeProductEntry.schema)
            .updateField("count", .float)
            .update()
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeProductEntry.schema)
            .updateField("count", .int64)
            .update()
    }
}
