import Foundation
import Fluent
import FluentSQL

struct MoveCountToQuantities: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.transaction { currentDatabase in
            try await currentDatabase.schema(DBRecipeProductEntry.schema)
                .field("quantities", .array(of: .json), .required, .sql(.default("{}")))
                .update()

            try await (currentDatabase as! any SQLDatabase).raw("""
                UPDATE "recipe-product-entry"
                SET "quantities" = ARRAY[jsonb_build_object('count', "count", 'quantityMeasure', "quantityMeasure")]
                WHERE "count" IS NOT NULL AND "quantityMeasure" IS NOT NULL
                """).run()

            try await currentDatabase.schema(DBRecipeProductEntry.schema)
                .deleteField("count")
                .deleteField("quantityMeasure")
                .update()
        }
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.transaction { currentDatabase in
            try await currentDatabase.schema(DBRecipeProductEntry.schema)
                .field("count", .float)
                .field("quantityMeasure", .int64)
                .update()

            try await (currentDatabase as! any SQLDatabase).raw("""
                UPDATE "recipe-product-entry"
                SET "count" = COALESCE(("quantities"[1] ->> 'count')::float, 0),
                    "quantityMeasure" = COALESCE(("quantities"[1] ->> 'quantityMeasure')::bigint, 0)
                """).run()

            try await currentDatabase.schema(DBRecipeProductEntry.schema)
                .deleteField("quantities")
                .update()
        }
    }
}
