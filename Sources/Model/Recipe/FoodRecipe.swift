import Foundation

public struct FoodRecipe: Codable, Sendable {
    public let id: String
    public let name: String
    public let shortDescription: String
    public let description: String
    public let products: [FoodRecipeProductEntry]
    public let tags: [Int]
    public let proteins: Double?
    public let fats: Double?
    public let carbohydrates: Double?
    public let calories: Double?

    public init(id: String,
         name: String,
         shortDescription: String,
         description: String,
         products: [FoodRecipeProductEntry],
         tags: [Int],
         proteins: Double?,
         fats: Double?,
         carbohydrates: Double?,
         calories: Double?
    ) {
        self.id = id
        self.name = name
        self.shortDescription = shortDescription
        self.description = description
        self.products = products
        self.tags = tags
        self.proteins = proteins
        self.fats = fats
        self.carbohydrates = carbohydrates
        self.calories = calories
    }
}
