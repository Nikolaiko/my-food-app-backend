import Foundation

public struct FoodRecipeQuantity: Codable, Sendable {
    public let count: Float
    public let quantityMeasure: FoodQuantityType

    public init(count: Float,
                quantityMeasure: FoodQuantityType
    ) {
        self.count = count
        self.quantityMeasure = quantityMeasure
    }
}
