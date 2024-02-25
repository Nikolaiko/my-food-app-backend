import Foundation
import Fluent
import Model

struct AddInitialRecipes: AsyncMigration {
    func prepare(on database: FluentKit.Database) async throws {
        try await database.transaction { currentDatabase in
            let vegtableSalad = DBRecipeEntry(
                name: AddInitialRecipes.RecipesData.recipeOneName,
                description: AddInitialRecipes.RecipesData.recipeOneDescription,
                shortDescription: AddInitialRecipes.RecipesData.recipeOneShortDescription
            )
            try await vegtableSalad.save(on: currentDatabase)


            let tomatoForSalad = DBRecipeProductEntry(
                count: 4,
                productType: .tomato,
                quantityMeasure: FoodQuantityType.item.rawValue,
                recipe: vegtableSalad.id!)

            let cucumberForSalad = DBRecipeProductEntry(
                count: 1,
                productType: .cucumber,
                quantityMeasure: FoodQuantityType.item.rawValue,
                recipe: vegtableSalad.id!)

            let sourCreamForSalad = DBRecipeProductEntry(
                count: 300,
                productType: .sourcream,
                quantityMeasure: FoodQuantityType.weight.rawValue,
                recipe: vegtableSalad.id!)

            try await tomatoForSalad.save(on: currentDatabase)
            try await cucumberForSalad.save(on: currentDatabase)
            try await sourCreamForSalad.save(on: currentDatabase)
        }
    }

    func revert(on database: FluentKit.Database) async throws {
        try await DBRecipeEntry
            .query(on: database)
            .filter(\.$name == AddInitialRecipes.RecipesData.recipeOneName)
            .filter(\.$shortDescription == AddInitialRecipes.RecipesData.recipeOneShortDescription)
            .filter(\.$description == AddInitialRecipes.RecipesData.recipeOneDescription)
            .delete()        
    }
}

private extension AddInitialRecipes {
    enum RecipesData {
        static let recipeOneName = "Овощной салат"
        static let recipeOneDescription = "Очень вкусное и простое, классическое блюдо"
        static let recipeOneShortDescription = "Попсовый салат"
    }
}
