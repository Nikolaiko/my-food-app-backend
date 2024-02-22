import Foundation
import Fluent

final class DBRecipeEntry: Model {
    static let schema: String = "recipe"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "shortDescription")
    var shortDescription: String

    @Children(for: \.$recipe)
    var products: [DBRecipeProductEntry]

    init() { }

    init(id: UUID? = nil,
         name: String,
         description: String,
         shortDescription: String
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.shortDescription = shortDescription
    }
}
