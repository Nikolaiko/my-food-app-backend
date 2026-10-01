import Foundation
import Testing
import Model

struct RecipeInputTests {
    @Test func decodesNewRecipeWithoutIds() throws {
        let json = """
        {"name": "Салат", "shortDescription": "Кратко", "description": "Полно", "tags": [1], "products": [{"productType": "Tomato", "quantities": [{"count": 4, "quantityMeasure": 3}]}]}
        """
        let recipe = try JSONDecoder().decode(NewFoodRecipe.self, from: Data(json.utf8))
        #expect(recipe.name == "Салат")
        #expect(recipe.tags == [1])
        #expect(recipe.products.map(\.productType) == [.tomato])
    }

    @Test func decodesNewRecipeWithLegacyEmptyIds() throws {
        let json = """
        {"id": "", "name": "Салат", "shortDescription": "Кратко", "description": "Полно", "tags": [], "products": [{"id": "", "productType": "Tomato", "quantities": []}]}
        """
        let recipe = try JSONDecoder().decode(NewFoodRecipe.self, from: Data(json.utf8))
        #expect(recipe.products.count == 1)
    }

    @Test func decodesRecipeUpdateIgnoringProductIds() throws {
        let json = """
        {"id": "59E038B3-629B-4749-88EB-F09234D87BBB", "name": "Салат", "shortDescription": "Кратко", "description": "Полно", "tags": [], "products": [{"id": "", "productType": "Tomato", "quantities": []}]}
        """
        let recipe = try JSONDecoder().decode(FoodRecipeUpdate.self, from: Data(json.utf8))
        #expect(recipe.id == "59E038B3-629B-4749-88EB-F09234D87BBB")
        #expect(recipe.products.map(\.productType) == [.tomato])
    }

    @Test func encodesNewRecipeWithoutIds() throws {
        let recipe = NewFoodRecipe(
            name: "Салат",
            shortDescription: "Кратко",
            description: "Полно",
            products: [NewFoodRecipeProductEntry(productType: .tomato, quantities: [])],
            tags: []
        )
        let json = String(decoding: try JSONEncoder().encode(recipe), as: UTF8.self)
        #expect(!json.contains(#""id""#))
    }
}
