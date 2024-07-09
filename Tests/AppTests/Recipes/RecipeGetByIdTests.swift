@testable import App

import XCTVapor
import Model

final class RecipeGetByIdTests: XCTestCase {

    func testGetRecipeById() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try await app.autoRevert().get()
        try await app.autoMigrate().get()

        try app.test(.POST, "/recipes/add", beforeRequest: { preRequest in
            try preRequest.content.encode(RecipesTestData.testRecipe)
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        }, afterResponse: { addResponse in
            XCTAssertEqual(addResponse.status, .ok)

            let addedRecipe = try addResponse.content.decode(FoodRecipe.self)
            try app.test(.GET, "recipes/\(addedRecipe.id)", beforeRequest: { preRequest in
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            }, afterResponse: { fullDataResponse in
                XCTAssertEqual(fullDataResponse.status, .ok)

                let newRecipe = try fullDataResponse.content.decode(FoodRecipe.self)

                //Test recipe
                XCTAssertEqual(newRecipe.name, RecipesTestData.testRecipe.name)
                XCTAssertEqual(newRecipe.shortDescription, RecipesTestData.testRecipe.shortDescription)
                XCTAssertEqual(newRecipe.description, RecipesTestData.testRecipe.description)
                XCTAssertTrue(newRecipe.tags.isEmpty)
                XCTAssertEqual(newRecipe.products.count, RecipesTestData.testRecipe.products.count)

                //Test product
                guard let product = newRecipe.products.first else {
                    XCTFail("No products in new recipe")
                    return
                }

                XCTAssertEqual(product.count, RecipesTestData.testRecipe.products[0].count)
                XCTAssertEqual(product.productType, RecipesTestData.testRecipe.products[0].productType)
                XCTAssertEqual(product.quantityMeasure, RecipesTestData.testRecipe.products[0].quantityMeasure)
            })
        })
    }

    func testGetRecipeByIdRecipeNotFoundError() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.GET, "/recipes/\(RecipesTestData.notExistingUUID)", beforeRequest: { preRequest in
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        }, afterResponse: { afterRequest in
            XCTAssert(
                afterRequest.status == .notFound,
                "Ожидаемый статус: \(HTTPStatus.notFound), полученный: \(afterRequest.status)"
            )
        })
    }

    func testGetRecipeByIdRecipeBadRequestError() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.GET, "/recipes/\(RecipesTestData.malformedgUUID)") { preRequest in
            try preRequest.content.encode(RecipesTestData.testDummyEntity)
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        } afterResponse: { afterRequest in
            XCTAssert(
                afterRequest.status == .badRequest,
                "Ожидаемый статус: \(HTTPStatus.badRequest), полученный: \(afterRequest.status)"
            )
        }
    }

    func testGetRecipeByIdNotAuthError() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.GET, "/recipes/\(RecipesTestData.notExistingUUID)", afterResponse: { afterRequest in
            XCTAssert(
                afterRequest.status == .unauthorized,
                "Ожидаемый статус: \(HTTPStatus.notFound), полученный: \(afterRequest.status)"
            )
        })
    }
}
