import Vapor
import Model

func routes(_ app: Application) throws {
    try app.register(collection: RecipeController())
}


let allRecipes: [FoodRecipe] = [
    FoodRecipe(
        id: "123",
        name: "234",
        shortDescription: "ee",
        description: "ewe",
        products: [],
        tags: []),
    FoodRecipe(
        id: "1234",
        name: "890",
        shortDescription: "aa",
        description: "456",
        products: [],
        tags: [])
]
