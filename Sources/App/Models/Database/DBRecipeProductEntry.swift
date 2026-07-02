import Foundation
import Fluent
@preconcurrency import Model

final class DBRecipeProductEntry: Model,  @unchecked Sendable {
    static let schema = "recipe-product-entry"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "count")
    var count: Int

    @Enum(key: "productType")
    var productType: FoodProductType

    @Field(key: "quantityMeasure")
    var quantityMeasure: Int

    @Parent(key: "recipe_id")
    var recipe: DBRecipeEntry

    init() { }

    init(id: UUID? = nil,
         count: Int,
         productType: FoodProductType,
         quantityMeasure: Int,
         recipe: DBRecipeEntry.IDValue
    ) {
        self.id = id
        self.count = count
        self.productType = productType
        self.quantityMeasure = quantityMeasure
        self.$recipe.id = recipe
    }
}
