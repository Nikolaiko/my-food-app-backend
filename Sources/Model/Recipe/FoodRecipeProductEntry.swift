import Foundation

public struct FoodRecipeProductEntry: Codable, Sendable {
    public let id: String
    public let productType: FoodProductType
    public let quantities: [FoodRecipeQuantity]

    public init(id: String,
                productType: FoodProductType,
                quantities: [FoodRecipeQuantity]
    ) {
        self.id = id
        self.productType = productType
        self.quantities = quantities
    }
}
