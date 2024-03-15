@testable import App

import XCTVapor
import Model

final class RecipeAddTests: XCTestCase {

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
                XCTFail("No products in new recipe")
                return
            }

            XCTAssertEqual(product.count, RecipesTestData.testRecipe.products[0].count)
            XCTAssertEqual(product.productType, RecipesTestData.testRecipe.products[0].productType)
            XCTAssertEqual(product.quantityMeasure, RecipesTestData.testRecipe.products[0].quantityMeasure)
        }
    }

    func testAddRecipeBadRequestError() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.POST, "/recipes/add") { preRequest in
            try preRequest.content.encode(RecipesTestData.testDummyEntity)
        } afterResponse: { afterRequest in
            XCTAssert(
                afterRequest.status == .badRequest,
                "Ожидаемый статус: \(HTTPStatus.badRequest), полученный: \(afterRequest.status)"
            )
        }
    }
}
