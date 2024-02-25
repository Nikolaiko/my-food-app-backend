import Foundation
import Vapor
import Model
import FluentKit

class RecipeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let recipeRoutes = routes.grouped("recipes")
        recipeRoutes.get(use: getAllRecipes)

        recipeRoutes.group(":\(ParameterNames.requestIdParameterName)") { idGroup in
            idGroup.get(use: getRecipeById)
        }
    }
    
    private func getRecipeById(request: Request) async throws -> FoodRecipe {
        guard let recipeId = request.parameters.get(ParameterNames.requestIdParameterName) else {
            throw CommonRequestError.unableToGetParameter(ParameterNames.requestIdParameterName)
        }
        guard let uuid = UUID(uuidString: recipeId),
              let recipeObject = try await DBRecipeEntry
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
}

private extension RecipeController {
    enum ParameterNames {
        static let requestIdParameterName = "recipeId"
    }
}
