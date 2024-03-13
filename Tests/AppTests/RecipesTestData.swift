import Foundation
import Model

enum RecipesTestData {
    static let testProductItem = FoodRecipeProductEntry(
        id: "",
        productType: FoodProductType.apple,
        count: 2,
        quantityMeasure: FoodQuantityType.item
    )

    static let testRecipe = FoodRecipe(
        id: "",
        name: "Яблочный рецепт",
        shortDescription: "Яблоки",
        description: "Про яблоки в тесте",
        products: [RecipesTestData.testProductItem],
        tags: []
    )
}
