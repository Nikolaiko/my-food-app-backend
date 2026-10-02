@testable import App

import XCTVapor
import Model

final class RecipeAddTests: XCTestCase {

    func testAddRecipe() async throws {
        try await Application.withTestable { app in
            let newRecipe = try await app.addRecipe(RecipesTestData.testRecipe)
            let expected = RecipesTestData.testRecipe

            XCTAssertNotNil(UUID(uuidString: newRecipe.id))
            XCTAssertEqual(newRecipe.name, expected.name)
            XCTAssertEqual(newRecipe.shortDescription, expected.shortDescription)
            XCTAssertEqual(newRecipe.description, expected.description)
            XCTAssertEqual(newRecipe.tags, expected.tags)
            XCTAssertEqual(newRecipe.proteins, expected.proteins)
            XCTAssertEqual(newRecipe.fats, expected.fats)
            XCTAssertEqual(newRecipe.carbohydrates, expected.carbohydrates)
            XCTAssertEqual(newRecipe.calories, expected.calories)
            XCTAssertEqual(newRecipe.products.count, expected.products.count)

            let product = try XCTUnwrap(newRecipe.products.first)
            let expectedProduct = expected.products[0]
            XCTAssertNotNil(UUID(uuidString: product.id))
            XCTAssertEqual(product.productType, expectedProduct.productType)
            XCTAssertEqual(product.quantities.map(\.count), expectedProduct.quantities.map(\.count))
            XCTAssertEqual(
                product.quantities.map(\.quantityMeasure),
                expectedProduct.quantities.map(\.quantityMeasure)
            )
        }
    }

    func testAddRecipeNotAuthError() async throws {
        try await Application.withTestable { app in
            try await app.test(.POST, "/recipes/add") { preRequest async throws in
                try preRequest.content.encode(RecipesTestData.testRecipe)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .unauthorized)
            }
        }
    }

    func testAddRecipeBadRequestError() async throws {
        try await Application.withTestable { app in
            try await app.test(.POST, "/recipes/add") { preRequest async throws in
                try preRequest.content.encode(RecipesTestData.testDummyEntity)
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .badRequest)
            }
        }
    }
}
