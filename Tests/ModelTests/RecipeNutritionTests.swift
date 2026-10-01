import Foundation
import Testing
import Model

struct RecipeNutritionTests {
    @Test func roundTripsNutrition() throws {
        let recipe = FoodRecipe(
            id: "1",
            name: "Салат",
            shortDescription: "Кратко",
            description: "Полно",
            products: [],
            tags: [],
            proteins: 12.5,
            fats: 0,
            carbohydrates: 30.25,
            calories: 310
        )
        let decoded = try JSONDecoder().decode(FoodRecipe.self, from: try JSONEncoder().encode(recipe))
        #expect(decoded.proteins == 12.5)
        #expect(decoded.fats == 0)
        #expect(decoded.carbohydrates == 30.25)
        #expect(decoded.calories == 310)
    }

    @Test func omitsMissingNutrition() throws {
        let recipe = FoodRecipe(
            id: "1",
            name: "Салат",
            shortDescription: "Кратко",
            description: "Полно",
            products: [],
            tags: [],
            proteins: nil,
            fats: nil,
            carbohydrates: nil,
            calories: nil
        )
        let json = String(decoding: try JSONEncoder().encode(recipe), as: UTF8.self)
        #expect(!json.contains("proteins"))
        #expect(!json.contains("fats"))
        #expect(!json.contains("carbohydrates"))
        #expect(!json.contains("calories"))
    }

    @Test func decodesAbsentAndNullNutritionAsNil() throws {
        let json = """
        {"name": "Салат", "shortDescription": "Кратко", "description": "Полно", "tags": [], "products": [], "proteins": null, "calories": 120.5}
        """
        let recipe = try JSONDecoder().decode(NewFoodRecipe.self, from: Data(json.utf8))
        #expect(recipe.proteins == nil)
        #expect(recipe.fats == nil)
        #expect(recipe.carbohydrates == nil)
        #expect(recipe.calories == 120.5)
    }
}
