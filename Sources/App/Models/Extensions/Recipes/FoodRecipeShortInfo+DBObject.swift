import Foundation

extension FoodRecipeShortInfo {
    static func fromDBObject(dbObject: DBRecipeEntry) -> FoodRecipeShortInfo {
        FoodRecipeShortInfo(
            id: dbObject.id?.uuidString ?? "",
            name: dbObject.name,
            shortDescription: dbObject.shortDescription,
            tags: []
        )
    }
}
