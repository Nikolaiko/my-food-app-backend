import Foundation
import Fluent
import FluentSQL

struct MakeRecipeColumnsNotNull: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.transaction { currentDatabase in
            let sql = currentDatabase as! any SQLDatabase

            try await sql.raw("""
                UPDATE "recipe"
                SET "name" = COALESCE("name", ''),
                    "description" = COALESCE("description", ''),
                    "shortDescription" = COALESCE("shortDescription", '')
                WHERE "name" IS NULL OR "description" IS NULL OR "shortDescription" IS NULL
                """).run()

            try await sql.raw("""
                UPDATE "recipe-product-entry"
                SET "productType" = 'Unknown'
                WHERE "productType" IS NULL
                """).run()

            try await sql.raw("""
                ALTER TABLE "recipe"
                    ALTER COLUMN "name" SET NOT NULL,
                    ALTER COLUMN "description" SET NOT NULL,
                    ALTER COLUMN "shortDescription" SET NOT NULL
                """).run()

            try await sql.raw("""
                ALTER TABLE "recipe-product-entry"
                    ALTER COLUMN "productType" SET NOT NULL
                """).run()
        }
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.transaction { currentDatabase in
            let sql = currentDatabase as! any SQLDatabase

            try await sql.raw("""
                ALTER TABLE "recipe"
                    ALTER COLUMN "name" DROP NOT NULL,
                    ALTER COLUMN "description" DROP NOT NULL,
                    ALTER COLUMN "shortDescription" DROP NOT NULL
                """).run()

            try await sql.raw("""
                ALTER TABLE "recipe-product-entry"
                    ALTER COLUMN "productType" DROP NOT NULL
                """).run()
        }
    }
}
