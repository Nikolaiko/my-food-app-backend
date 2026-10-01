import Foundation

public struct NewFoodRecipeProductEntry: Codable, Sendable {
    public let productType: FoodProductType
    public let quantities: [FoodRecipeQuantity]

    public init(productType: FoodProductType,
                quantities: [FoodRecipeQuantity]
    ) {
        self.productType = productType
        self.quantities = quantities
    }
}
