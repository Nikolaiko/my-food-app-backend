import Foundation
import Fluent

final class DBRecipeEntry: Model,  @unchecked Sendable {
    static let schema: String = "recipe"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "shortDescription")
    var shortDescription: String

    @Field(key: "description")
    var description: String

    @Children(for: \.$recipe)
    var products: [DBRecipeProductEntry]

    @Field(key: "tags")
    var tags: [Int]

    @OptionalField(key: "proteins")
    var proteins: Double?

    @OptionalField(key: "fats")
    var fats: Double?

    @OptionalField(key: "carbohydrates")
    var carbohydrates: Double?

    @OptionalField(key: "calories")
    var calories: Double?

    init() { }

    init(id: UUID? = nil,
         name: String,
         shortDescription: String,
         description: String,
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
        self.tags = tags
        self.proteins = proteins
        self.fats = fats
        self.carbohydrates = carbohydrates
        self.calories = calories
    }
}
