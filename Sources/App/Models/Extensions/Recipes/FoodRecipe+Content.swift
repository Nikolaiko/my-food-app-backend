import Foundation
import Model
import Vapor

extension FoodRecipe: Content {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case shortDescription
        case description
        case products
        case tags
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(shortDescription, forKey: .shortDescription)
        try container.encode(tags, forKey: .tags)
        try container.encode(products, forKey: .products)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(String.self, forKey: .id)
        let name = try values.decode(String.self, forKey: .name)
        let description = try values.decode(String.self, forKey: .description)
        let shortDescription = try values.decode(String.self, forKey: .shortDescription)
        let tags = try values.decode([Int].self, forKey: .tags)
        let products = try values.decode([FoodRecipeProductEntry].self, forKey: .products)

        self.init(id: id,
                  name: name,
                  shortDescription: shortDescription,
                  description: description,
                  products: products,
                  tags: tags)
    }
}
