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

    func addNewRecipe(newRecipe: NewFoodRecipe, db: any Database) async throws -> FoodRecipe {
        try await db.transaction { currentDb in
            let dbRecipe = newRecipe.toDBObject()
            try await dbRecipe.save(on: currentDb)

            let dbProductEntries = newRecipe.products.map { $0.toDBObject(parentRecipe: dbRecipe) }
            for currentEntry in dbProductEntries {
                try await currentEntry.save(on: currentDb)
            }

            guard let savedRecipe = try await getRecipeById(uuid: try dbRecipe.requireID(), db: currentDb) else {
                throw CommonRequestError.notFound
            }
            return savedRecipe
        }
    }

    func updateRecipe(uuid: UUID, newRecipe: FoodRecipeUpdate, db: any Database) async throws -> FoodRecipe {
        try await db.transaction { currentDb in
            guard let dbRecipe = try await DBRecipeEntry
                .query(on: currentDb)
                .filter(\.$id == uuid)
                .first() else {
                throw CommonRequestError.notFound
            }

            dbRecipe.name = newRecipe.name
            dbRecipe.shortDescription = newRecipe.shortDescription
            dbRecipe.description = newRecipe.description
            dbRecipe.tags = newRecipe.tags
            try await dbRecipe.update(on: currentDb)

            try await DBRecipeProductEntry
                .query(on: currentDb)
                .filter(\.$recipe.$id == uuid)
                .delete()

            let dbProductEntries = newRecipe.products.map { recipeEntry in
                recipeEntry.toDBObject(parentRecipe: dbRecipe)
            }

            for currentEntry in dbProductEntries {
                try await currentEntry.save(on: currentDb)
            }

            guard let savedRecipe = try await getRecipeById(uuid: uuid, db: currentDb) else {
                throw CommonRequestError.notFound
            }
            return savedRecipe
        }
    }
}
