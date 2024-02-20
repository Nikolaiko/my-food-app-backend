import Vapor
import Model

func routes(_ app: Application) throws {
    app.group("recipes") { recipes in
        recipes.get { request in
            "return recipes"
        }
    }
}


let recipes: [FoodRecipe] = [
    FoodRecipe(
        id: "123",
        name: "234",
        shortDescription: "ee",
        description: "ewe",
        products: [],
        tags: [])
]
