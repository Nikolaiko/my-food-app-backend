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

    func toDBObject(parentRecipe: DBRecipeEntry) -> DBRecipeProductEntry {
        DBRecipeProductEntry(
            id: self.id.isEmpty ? nil : UUID(uuidString: self.id),
            count: self.count,
            productType: self.productType,
            quantityMeasure: self.quantityMeasure.rawValue,
            recipe: parentRecipe.id!
        )
    }

    func copy(
        newId: String? = nil,
        newCount: Int? = nil,
        newProductType: FoodProductType? = nil,
        newQuantityMeasureType: FoodQuantityType? = nil
    ) -> FoodRecipeProductEntry {
        FoodRecipeProductEntry(
            id: newId ?? id,
            productType: newProductType ?? productType,
            count: newCount ?? count,
            quantityMeasure: newQuantityMeasureType ?? quantityMeasure
        )
    }
}
