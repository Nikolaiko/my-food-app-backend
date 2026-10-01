import Foundation
import Model

enum RecipesTestData {
    static let testProductItem = NewFoodRecipeProductEntry(
        productType: FoodProductType.apple,
        quantities: [FoodRecipeQuantity(count: 2, quantityMeasure: FoodQuantityType.item)]
    )

    static let testRecipe = NewFoodRecipe(
        name: "Яблочный рецепт",
        shortDescription: "Яблоки",
        description: "Про яблоки в тесте",
        products: [RecipesTestData.testProductItem],
        tags: []
    )

    static let notExistingUUID = "13E038B3-629B-4749-88EB-F09234D87567"
    static let malformedgUUID = "wrongValueUUID"
    static let newName = "Новый овощной салат"
    static let newDescription = "Новое описание"
    static let newProductsCount = 2

    static let newFirstProductItem = NewFoodRecipeProductEntry(
        productType: FoodProductType.cottage,
        quantities: [FoodRecipeQuantity(count: 4, quantityMeasure: FoodQuantityType.item)]
    )

    static let newSecondProductItem = NewFoodRecipeProductEntry(
        productType: FoodProductType.bellpepper,
        quantities: [FoodRecipeQuantity(count: 4, quantityMeasure: FoodQuantityType.weight)]
    )

    static let testDummyEntity = DummyTestEntity(name: "some", id: "123")
}
