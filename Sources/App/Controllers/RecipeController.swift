import Foundation
import Vapor
import Model
import FluentKit

class RecipeController: RouteCollection {
    private let provider = DataProvider()

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
        guard let recipeObject = try await provider.getRecipeById(uuid: uuid, db: request.db) else {
            throw CommonRequestError.notFound
        }
        return recipeObject
    }

    private func getAllRecipes(request: Request) async throws -> [FoodRecipeShortInfo] {
        return try await provider.getAllRecipes(db: request.db)
    }

    private func updateRecipeById(request: Request) async throws -> FoodRecipe {
        guard let parsedRecipe = try? request.content.decode(FoodRecipe.self),
              let uuid = UUID(uuidString: parsedRecipe.id) else {
            throw CommonRequestError.unableToParseParameter(ParameterNames.recipeInBody)
        }

        return try await provider.updateRecipe(
            uuid: uuid,
            newRecipe: parsedRecipe,
            db: request.db
        )
    }

    private func addRecipe(request: Request) async throws -> FoodRecipe {
        guard let parsedRecipe = try? request.content.decode(FoodRecipe.self) else {
            throw CommonRequestError.unableToParseParameter(ParameterNames.recipeInBody)
        }
        return try await provider.addNewRecipe(
            newRecipe: parsedRecipe,
            db: request.db
        )
    }

}

private extension RecipeController {
    enum ParameterNames {
        static let requestIdParameterName = "recipeId"
        static let recipeInBody = "recipe from body"
    }
}
