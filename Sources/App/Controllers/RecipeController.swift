import Foundation
import Vapor
import Model
import FluentKit

class RecipeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let recipeRoutes = routes.grouped("recipes")

        recipeRoutes.get(use: getAllRecipes)
        recipeRoutes.put(use: updateRecipeById)

        recipeRoutes.group("add") { addGroup in
            addGroup.post(use: addRecipe)
        }

        recipeRoutes.group(":\(ParameterNames.requestIdParameterName)") { idGroup in
            idGroup.get(use: getRecipeById)
        }
    }

    private func getRecipeById(request: Request) async throws -> FoodRecipe {
        guard let recipeId = request.parameters.get(ParameterNames.requestIdParameterName),
              let uuid = UUID(uuidString: recipeId) else {
            throw CommonRequestError.unableToGetParameter(ParameterNames.requestIdParameterName)
        }
        guard let recipeObject = try await DBRecipeEntry
            .query(on: request.db)
            .filter(\.$id == uuid)
            .with(\.$products)
            .first() else {
            throw CommonRequestError.notFound
        }
        return FoodRecipe.fromDBObject(dbObject: recipeObject)
    }

    private func getAllRecipes(request: Request) async throws -> [FoodRecipeShortInfo] {
        let recipiesObjects = try await DBRecipeEntry
            .query(on: request.db)
            .all()
        return recipiesObjects.map { FoodRecipeShortInfo.fromDBObject(dbObject: $0) }
    }

    private func updateRecipeById(request: Request) async throws -> FoodRecipe {
        guard let parsedRecipe = try? request.content.decode(FoodRecipe.self),
              let uuid = UUID(uuidString: parsedRecipe.id) else {
            throw CommonRequestError.unableToParseParameter(ParameterNames.recipeInBody)
        }

        try await request.db.transaction { currentDb in
            try await DBRecipeEntry
                .query(on: currentDb)
                .filter(\.$id == uuid)
                .delete()

            let dbRecipe = parsedRecipe.toDBObject()
            try await dbRecipe.save(on: currentDb)

            let dbProductEntries = parsedRecipe.products.map { recipeEntry in
                recipeEntry.toDBObject(parentRecipe: dbRecipe)
            }

            for currentEntry in dbProductEntries {
                try await currentEntry.save(on: currentDb)
            }
        }
        return parsedRecipe
    }

    private func addRecipe(request: Request) async throws -> FoodRecipe {
        guard let parsedRecipe = try? request.content.decode(FoodRecipe.self) else {
            throw CommonRequestError.unableToParseParameter(ParameterNames.recipeInBody)
        }

        try await request.db.transaction { currentDb in
            let dbRecipe = parsedRecipe.toDBObject()

            try await dbRecipe.save(on: currentDb)

            let dbProductEntries = parsedRecipe.products.map { $0.toDBObject(parentRecipe: dbRecipe) }

            for currentEntry in dbProductEntries {
                try await currentEntry.save(on: currentDb)
            }
        }

        return parsedRecipe
    }
}

private extension RecipeController {
    enum ParameterNames {
        static let requestIdParameterName = "recipeId"
        static let recipeInBody = "recipe from body"
    }
}
