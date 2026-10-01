import Foundation
import Model

extension NewFoodRecipeProductEntry {
    func toDBObject(parentRecipe: DBRecipeEntry) -> DBRecipeProductEntry {
        DBRecipeProductEntry(
            productType: self.productType,
            quantities: self.quantities,
            recipe: parentRecipe.id!
        )
    }
}
