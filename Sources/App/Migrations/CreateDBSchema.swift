import Foundation
import Fluent
import Model

struct CreateDBSchema: AsyncMigration {

    func prepare(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeEntry.schema)
                    .id()
                    .field("name", .string)
                    .field("description", .string)
                    .field("shortDescription", .string)
                    .create()

        try await database.schema(DBRecipeProductEntry.schema)
                    .id()
                    .field("count", .int64)
                    .field("quantityMeasure", .int64)
                    .field("productType", .string)
                    .field("recipe_id", .uuid, .required, .references("recipe", "id"))
                    .create()

        let vegtableSalad = DBRecipeEntry(
            name: "Овощной салат",
            description: "Очень вкусное и простое, классическое блюдо",
            shortDescription: "Попсовый салат"
        )

        try await vegtableSalad.save(on: database)

        database.logger.info("\(vegtableSalad.id)")

        let tomatoForSalad = DBRecipeProductEntry(
            count: 4,
            productType: .tomato,
            quantityMeasure: FoodQuantityType.item.rawValue,
            recipe: vegtableSalad.id!)

        let cucumberForSalad = DBRecipeProductEntry(
            count: 1,
            productType: .cucumber,
            quantityMeasure: FoodQuantityType.item.rawValue,
            recipe: vegtableSalad.id!)

        let sourCreamForSalad = DBRecipeProductEntry(
            count: 300,
            productType: .sourcream,
            quantityMeasure: FoodQuantityType.weight.rawValue,
            recipe: vegtableSalad.id!)


        try await tomatoForSalad.save(on: database)
        try await cucumberForSalad.save(on: database)
        try await sourCreamForSalad.save(on: database)

        database.logger.info("\(tomatoForSalad.id)")

        //try await vegtableSalad.$products.create(tomatoForSalad, on: database)
        //try await vegtableSalad.$products.create(cucumberForSalad, on: database)
        //try await vegtableSalad.$products.create(sourCreamForSalad, on: database)

        //try await vegtableSalad.save(on: database)
    }

    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(DBRecipeProductEntry.schema).delete()
        try await database.schema(DBRecipeEntry.schema).delete()
    }
}

private extension CreateDBSchema {





}
