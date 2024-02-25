import Foundation
import Model

extension FoodRecipeProductEntry {
    static func fromDBObject(dbObject: DBRecipeProductEntry) -> FoodRecipeProductEntry {
        FoodRecipeProductEntry(
            id: dbObject.id?.uuidString ?? "",
            productType: dbObject.productType,
            count: dbObject.count,
            quantityMeasure: FoodQuantityType(rawValue: dbObject.quantityMeasure) ?? .unknown
        )
    }
}
