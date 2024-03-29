import Foundation
import Model

extension FoodRecipe {
    static func fromDBObject(dbObject: DBRecipeEntry) -> FoodRecipe {
        FoodRecipe(
            id: dbObject.id?.uuidString ?? "",
            name: dbObject.name,
            shortDescription: dbObject.shortDescription,
            description: dbObject.description,
            products: dbObject.products.map { FoodRecipeProductEntry.fromDBObject(dbObject: $0) },
            tags: []
        )
    }

    func toDBObject() -> DBRecipeEntry {
        DBRecipeEntry(
            id: self.id.isEmpty ? nil : UUID(uuidString: self.id),
            name: self.name,
            description: self.description,
            shortDescription: self.shortDescription
        )
    }

    func copy(
        newId: String? = nil,
        newName: String? = nil,
        newShortDescription: String? = nil,
        newDescription: String? = nil,
        newTags: [Int]? = nil,
        newProducts: [FoodRecipeProductEntry]? = nil
    ) -> FoodRecipe {
        FoodRecipe(
            id: newId ?? id,
            name: newName ?? name,
            shortDescription: newShortDescription ?? shortDescription,
            description: newDescription ?? description,
            products: newProducts ?? products,
            tags: newTags ?? tags
        )
    }
}
