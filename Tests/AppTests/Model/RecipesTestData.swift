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

    static let notExistingUUID = "13E038B3-629B-4749-88EB-F09234D87567"
    static let malformedgUUID = "wrongValueUUID"
    static let newName = "Новый овощной салат"
    static let newDescription = "Новое описание"
    static let newProductsCount = 2

    static let newFirstProductItem = FoodRecipeProductEntry(
        id: "",
        productType: FoodProductType.cottage,
        count: 4,
        quantityMeasure: FoodQuantityType.item
    )

    static let newSecondProductItem = FoodRecipeProductEntry(
        id: "",
        productType: FoodProductType.bellpepper,
        count: 4,
        quantityMeasure: FoodQuantityType.weight
    )

    static let testDummyEntity = DummyTestEntity(name: "some", id: "123")
}
