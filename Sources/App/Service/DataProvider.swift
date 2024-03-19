import Foundation
import Vapor
import Model
import FluentKit

struct DataProvider {

    func getRecipeById(uuid: UUID, db: any Database) async throws -> FoodRecipe? {
        guard let recipe = try await DBRecipeEntry
            .query(on: db)
            .filter(\.$id == uuid)
            .with(\.$products)
            .first() else { return nil }
        return FoodRecipe.fromDBObject(dbObject: recipe)
    }

    func getAllRecipes(db: any Database) async throws -> [FoodRecipeShortInfo] {
        let recipiesObjects = try await DBRecipeEntry
            .query(on: db)
            .all()
        return recipiesObjects.map { FoodRecipeShortInfo.fromDBObject(dbObject: $0) }
    }

    func addNewRecipe(newRecipe: FoodRecipe, db: any Database) async throws -> FoodRecipe {
        try await db.transaction { currentDb in
            let dbRecipe = newRecipe.toDBObject()
            try await dbRecipe.save(on: currentDb)

            let dbProductEntries = newRecipe.products.map { $0.toDBObject(parentRecipe: dbRecipe) }
            for currentEntry in dbProductEntries {
                try await currentEntry.save(on: currentDb)
            }

            var productItemsWithId: [FoodRecipeProductEntry] = []
            for index in (0..<dbProductEntries.count) {
                productItemsWithId.append(
                    newRecipe.products[index].copy(newId: dbProductEntries[index].id?.uuidString)
                )
            }

            let recipeWithId = newRecipe.copy(
                newId: dbRecipe.id?.uuidString,
                newProducts: productItemsWithId
            )
            return recipeWithId
        }
    }

    func updateRecipe(uuid: UUID, newRecipe: FoodRecipe, db: any Database) async throws -> FoodRecipe {
        try await db.transaction { currentDb in
            guard let oldRecipe = try await DBRecipeEntry
                .query(on: currentDb)
                .filter(\.$id == uuid)
                .first() else {
                throw CommonRequestError.notFound
            }

            try await DBRecipeEntry
                .query(on: currentDb)
                .filter(\.$id == uuid)
                .delete()

            let dbRecipe = newRecipe.toDBObject()
            try await dbRecipe.save(on: currentDb)

            let dbProductEntries = newRecipe.products.map { recipeEntry in
                recipeEntry.toDBObject(parentRecipe: dbRecipe)
            }

            for currentEntry in dbProductEntries {
                try await currentEntry.save(on: currentDb)
            }
            return newRecipe
        }
    }
}
