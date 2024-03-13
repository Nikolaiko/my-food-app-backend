@testable import App

import XCTVapor
import Model

final class AppTests: XCTestCase {

    func testGetAllRecipes() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.GET, "/recipes", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)

            let recipes = try response.content.decode([FoodRecipeShortInfo].self)

            XCTAssertEqual(recipes.count, 1)
            guard let initialRecipe = recipes.first else {
                XCTFail("No initial recipe!")
                return
            }

            XCTAssertEqual(initialRecipe.name, InitialDBData.recipeOneName)
            XCTAssertEqual(initialRecipe.shortDescription, InitialDBData.recipeOneShortDescription)
            XCTAssertTrue(initialRecipe.tags.isEmpty)
        })
    }

    func testAddRecipe() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.POST, "/recipes/add") { preRequest in
            try preRequest.content.encode(RecipesTestData.testRecipe)
        } afterResponse: { addResponse in
            XCTAssertEqual(addResponse.status, .ok)
            
            guard let newRecipe = try? addResponse.content.decode(FoodRecipe.self) else {
                XCTFail("Unable to parse response after add recipe")
                return
            }
            
            //Test Recipe
            XCTAssertEqual(newRecipe.name, RecipesTestData.testRecipe.name)
            XCTAssertEqual(newRecipe.shortDescription, RecipesTestData.testRecipe.shortDescription)
            XCTAssertEqual(newRecipe.description, RecipesTestData.testRecipe.description)
            XCTAssertTrue(newRecipe.tags.isEmpty)
            XCTAssertEqual(newRecipe.products.count, RecipesTestData.testRecipe.products.count)

            //Test Product
            guard let product = newRecipe.products.first else {
                XCTFail("UNo products in new recipe")
                return
            }

            XCTAssertEqual(product.count, RecipesTestData.testRecipe.products[0].count)
            XCTAssertEqual(product.productType, RecipesTestData.testRecipe.products[0].productType)
            XCTAssertEqual(product.quantityMeasure, RecipesTestData.testRecipe.products[0].quantityMeasure)
        }
    }

    func testGetRecipeById() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try await app.autoRevert().get()
        try await app.autoMigrate().get()

        try app.test(.POST, "/recipes/add", beforeRequest: { preRequest in
            try preRequest.content.encode(RecipesTestData.testRecipe)
        }, afterResponse: { addResponse in
            XCTAssertEqual(addResponse.status, .ok)

            let addedRecipe = try addResponse.content.decode(FoodRecipe.self)
            try app.test(.GET, "recipes/\(addedRecipe.id)") { fullDataResponse in
                XCTAssertEqual(fullDataResponse.status, .ok)

                let newRecipe = try fullDataResponse.content.decode(FoodRecipe.self)
                XCTAssertEqual(newRecipe.name, RecipesTestData.testRecipe.name)
                XCTAssertEqual(newRecipe.shortDescription, RecipesTestData.testRecipe.shortDescription)
                XCTAssertEqual(newRecipe.description, RecipesTestData.testRecipe.description)
                XCTAssertTrue(newRecipe.tags.isEmpty)
                XCTAssertEqual(newRecipe.products.count, RecipesTestData.testRecipe.products.count)
            }
        })
    }

    func testModifyById() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try await app.autoRevert().get()
        try await app.autoMigrate().get()

        try app.test(.GET, "/recipes", afterResponse: { allRecipesResponse in
            XCTAssertEqual(allRecipesResponse.status, .ok)

            let recipes = try allRecipesResponse.content.decode([FoodRecipeShortInfo].self)
            XCTAssertEqual(recipes.count, 1)
            guard let initialRecipe = recipes.first else {
                XCTFail("No initial recipe!")
                return
            }

            try app.test(.GET, "recipes/\(initialRecipe.id)") { fullDataResponse in
                let fullRecipe = try fullDataResponse.content.decode(FoodRecipe.self)
                let newName = "Новый овощной салат"
                let newDescription = "Новое описание"
                let newProductsCount = 1
                let newProductItem = FoodRecipeProductEntry(
                    id: "",
                    productType: FoodProductType.cottage,
                    count: 4,
                    quantityMeasure: FoodQuantityType.item
                )
                let newRecipe = FoodRecipe(
                    id: fullRecipe.id,
                    name: newName,
                    shortDescription: fullRecipe.shortDescription,
                    description: newDescription,
                    products: [newProductItem],
                    tags: []
                )


            }
        })
    }
}
