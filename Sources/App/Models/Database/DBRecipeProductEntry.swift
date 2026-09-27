import Foundation
import Fluent
import Model

final class DBRecipeProductEntry: Model,  @unchecked Sendable {
    static let schema = "recipe-product-entry"

    @ID(key: .id)
    var id: UUID?

    @Enum(key: "productType")
    var productType: FoodProductType

    @Field(key: "quantities")
    var quantities: [FoodRecipeQuantity]

    @Parent(key: "recipe_id")
    var recipe: DBRecipeEntry

    init() { }

    init(id: UUID? = nil,
         productType: FoodProductType,
         quantities: [FoodRecipeQuantity],
         recipe: DBRecipeEntry.IDValue
    ) {
        self.id = id
        self.productType = productType
        self.quantities = quantities
        self.$recipe.id = recipe
    }
}
