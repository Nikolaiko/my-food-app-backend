import Foundation
import Vapor
import Model

class RecipeController: RouteCollection {
    func boot(routes: Vapor.RoutesBuilder) throws {
        let recipeRoutes = routes.grouped("recipes")
        recipeRoutes.get(use: getAllRecipes)

    }
    
    private func getAllRecipes(request: Request) throws -> [FoodRecipe] {        
        allRecipes
    }
}
