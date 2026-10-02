@testable import App

import XCTVapor
import Model

final class RecipeGetByIdTests: XCTestCase {

    func testGetRecipeById() async throws {
        try await Application.withTestable { app in
            let addedRecipe = try await app.addRecipe(RecipesTestData.testRecipe)

            try await app.test(.GET, "/recipes/\(addedRecipe.id)") { preRequest async throws in
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)

                let recipe = try response.content.decode(FoodRecipe.self)
                let expected = RecipesTestData.testRecipe

                XCTAssertEqual(recipe.id, addedRecipe.id)
                XCTAssertEqual(recipe.name, expected.name)
                XCTAssertEqual(recipe.shortDescription, expected.shortDescription)
                XCTAssertEqual(recipe.description, expected.description)
                XCTAssertEqual(recipe.tags, expected.tags)
                XCTAssertEqual(recipe.proteins, expected.proteins)
                XCTAssertEqual(recipe.fats, expected.fats)
                XCTAssertEqual(recipe.carbohydrates, expected.carbohydrates)
                XCTAssertEqual(recipe.calories, expected.calories)
                XCTAssertEqual(recipe.products.count, expected.products.count)

                let product = try XCTUnwrap(recipe.products.first)
                let expectedProduct = expected.products[0]
                XCTAssertEqual(product.id, addedRecipe.products.first?.id)
                XCTAssertEqual(product.productType, expectedProduct.productType)
                XCTAssertEqual(product.quantities.map(\.count), expectedProduct.quantities.map(\.count))
                XCTAssertEqual(
                    product.quantities.map(\.quantityMeasure),
                    expectedProduct.quantities.map(\.quantityMeasure)
                )
            }
        }
    }

    func testGetRecipeByIdRecipeNotFoundError() async throws {
        try await Application.withTestable { app in
            try await app.test(.GET, "/recipes/\(RecipesTestData.notExistingUUID)") { preRequest async throws in
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .notFound)
            }
        }
    }

    func testGetRecipeByIdRecipeBadRequestError() async throws {
        try await Application.withTestable { app in
            try await app.test(.GET, "/recipes/\(RecipesTestData.malformedgUUID)") { preRequest async throws in
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .badRequest)
            }
        }
    }

    func testGetRecipeByIdNotAuthError() async throws {
        try await Application.withTestable { app in
            try await app.test(.GET, "/recipes/\(RecipesTestData.notExistingUUID)") { response async throws in
                XCTAssertEqual(response.status, .unauthorized)
            }
        }
    }
}
