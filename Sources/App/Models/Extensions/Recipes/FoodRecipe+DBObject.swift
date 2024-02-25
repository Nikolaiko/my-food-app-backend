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
}
