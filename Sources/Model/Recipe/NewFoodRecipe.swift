import Foundation

public struct NewFoodRecipe: Codable, Sendable {
    public let name: String
    public let shortDescription: String
    public let description: String
    public let products: [NewFoodRecipeProductEntry]
    public let tags: [Int]

    public init(name: String,
                shortDescription: String,
                description: String,
                products: [NewFoodRecipeProductEntry],
                tags: [Int]
    ) {
        self.name = name
        self.shortDescription = shortDescription
        self.description = description
        self.products = products
        self.tags = tags
    }
}
