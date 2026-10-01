import Foundation
import Model

extension NewFoodRecipe {
    func toDBObject() -> DBRecipeEntry {
        DBRecipeEntry(
            name: self.name,
            shortDescription: self.shortDescription,
            description: self.description,
            tags: self.tags
        )
    }
}
