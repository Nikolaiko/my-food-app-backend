import Foundation
import Fluent
import FluentSQL
import Model

struct AddInitialRecipes: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.transaction { currentDatabase in
            let sql = currentDatabase as! any SQLDatabase
            let vegtableSaladId = UUID()

            try await sql.insert(into: DBRecipeEntry.schema)
                .columns("id", "name", "description", "shortDescription")
                .values(
                    vegtableSaladId,
                    InitialDBData.recipeOneName,
                    InitialDBData.recipeOneDescription,
                    InitialDBData.recipeOneShortDescription
                )
                .run()

            try await sql.insert(into: DBRecipeProductEntry.schema)
                .columns("id", "count", "productType", "quantityMeasure", "recipe_id")
                .values(
                    UUID(),
                    InitialDBData.initialTomatoCount,
                    FoodProductType.tomato.rawValue,
                    InitialDBData.initialTomatoQuantityType.rawValue,
                    vegtableSaladId
                )
                .values(
                    UUID(),
                    InitialDBData.initialCucmberCount,
                    FoodProductType.cucumber.rawValue,
                    InitialDBData.initialCucmberQuantityType.rawValue,
                    vegtableSaladId
                )
                .values(
                    UUID(),
                    InitialDBData.initialCreamCount,
                    FoodProductType.sourcream.rawValue,
                    InitialDBData.initialCreamQuantityType.rawValue,
                    vegtableSaladId
                )
                .run()
        }
    }

    func revert(on database: FluentKit.Database) async throws {
        try await DBRecipeEntry
            .query(on: database)
            .filter(\.$name == InitialDBData.recipeOneName)
            .filter(\.$shortDescription == InitialDBData.recipeOneShortDescription)
            .filter(\.$description == InitialDBData.recipeOneDescription)
            .delete()        
    }
}
