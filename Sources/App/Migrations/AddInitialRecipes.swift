import Foundation
import Fluent
import Model

struct AddInitialRecipes: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.transaction { currentDatabase in
            let vegtableSalad = DBRecipeEntry(
                name: InitialDBData.recipeOneName,
                description: InitialDBData.recipeOneDescription,
                shortDescription: InitialDBData.recipeOneShortDescription
            )
            try await vegtableSalad.save(on: currentDatabase)


            let tomatoForSalad = DBRecipeProductEntry(
                count: InitialDBData.initialTomatoCount,
                productType: .tomato,
                quantityMeasure: InitialDBData.initialTomatoQuantityType.rawValue,
                recipe: vegtableSalad.id!)

            let cucumberForSalad = DBRecipeProductEntry(
                count: InitialDBData.initialCucmberCount,
                productType: .cucumber,
                quantityMeasure: InitialDBData.initialCucmberQuantityType.rawValue,
                recipe: vegtableSalad.id!)

            let sourCreamForSalad = DBRecipeProductEntry(
                count: InitialDBData.initialCreamCount,
                productType: .sourcream,
                quantityMeasure: InitialDBData.initialCreamQuantityType.rawValue,
                recipe: vegtableSalad.id!)

            try await tomatoForSalad.save(on: currentDatabase)
            try await cucumberForSalad.save(on: currentDatabase)
            try await sourCreamForSalad.save(on: currentDatabase)
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
