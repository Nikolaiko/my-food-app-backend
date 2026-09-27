import Foundation
import Model

extension FoodRecipeProductEntry {
    static func fromDBObject(dbObject: DBRecipeProductEntry) -> FoodRecipeProductEntry {
        FoodRecipeProductEntry(
            id: dbObject.id?.uuidString ?? "",
            productType: dbObject.productType,
            quantities: dbObject.quantities
        )
    }

    func toDBObject(parentRecipe: DBRecipeEntry) -> DBRecipeProductEntry {
        DBRecipeProductEntry(
            id: self.id.isEmpty ? nil : UUID(uuidString: self.id),
            productType: self.productType,
            quantities: self.quantities,
            recipe: parentRecipe.id!
        )
    }

    func copy(
        newId: String? = nil,
        newProductType: FoodProductType? = nil,
        newQuantities: [FoodRecipeQuantity]? = nil
    ) -> FoodRecipeProductEntry {
        FoodRecipeProductEntry(
            id: newId ?? id,
            productType: newProductType ?? productType,
            quantities: newQuantities ?? quantities
        )
    }
}
