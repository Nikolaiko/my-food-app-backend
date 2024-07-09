@testable import App

import XCTVapor
import Model

final class RecipeModifyTests: XCTestCase {

    func testModifyById() async throws {
        let app = try await Application.testable()

        try app.test(.POST, "/recipes/add") { preRequest in
            try preRequest.content.encode(RecipesTestData.testRecipe)
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        } afterResponse: { addResponse in
            XCTAssertEqual(addResponse.status, .ok)

            guard let initialRecipe = try? addResponse.content.decode(FoodRecipe.self) else {
                XCTFail("Unable to parse response after add recipe")
                return
            }


            let newRecipe = initialRecipe.copy(
                newName: RecipesTestData.newName,
                newDescription: RecipesTestData.newDescription,
                newProducts: [
                    RecipesTestData.newFirstProductItem,
                    RecipesTestData.newSecondProductItem
                ]
            )

            try app.test(.PUT, "/recipes") { inputRequest in
                try inputRequest.content.encode(newRecipe)
                inputRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { modifyedRecipe in
                XCTAssertEqual(modifyedRecipe.status, .ok)

                guard let modifiedRecipe = try? modifyedRecipe.content.decode(FoodRecipe.self) else {
                    XCTFail("Unable to parse response after modyfing recipe")
                    return
                }

                //Test recipe
                XCTAssertEqual(modifiedRecipe.name, RecipesTestData.newName)
                XCTAssertEqual(modifiedRecipe.description, RecipesTestData.newDescription)
                XCTAssertTrue(modifiedRecipe.tags.isEmpty)
                XCTAssertEqual(modifiedRecipe.products.count, 2)
            }
        }
    }

    func testModifyRecipeNotFoundError() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        let newRecipe = FoodRecipe(
            id: RecipesTestData.notExistingUUID,
            name: RecipesTestData.newName,
            shortDescription: RecipesTestData.newDescription,
            description: RecipesTestData.newDescription,
            products: [],
            tags: []
        )

        try app.test(.PUT, "/recipes") { preRequest in
            try preRequest.content.encode(newRecipe)
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        } afterResponse: { afterRequest in
            XCTAssert(
                afterRequest.status == .notFound,
                "Ожидаемый статус: \(HTTPStatus.notFound), полученный: \(afterRequest.status)"
            )
        }
    }

    func testModifyRecipeBadRequestError() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.PUT, "/recipes") { preRequest in
            try preRequest.content.encode(RecipesTestData.testDummyEntity)
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        } afterResponse: { afterRequest in
            XCTAssert(
                afterRequest.status == .badRequest,
                "Ожидаемый статус: \(HTTPStatus.badRequest), полученный: \(afterRequest.status)"
            )
        }
    }

    func testModifyByIdAuthError() async throws {
        let app = try await Application.testable()

        try app.test(.POST, "/recipes/add") { preRequest in
            try preRequest.content.encode(RecipesTestData.testRecipe)
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        } afterResponse: { addResponse in
            XCTAssertEqual(addResponse.status, .ok)

            guard let initialRecipe = try? addResponse.content.decode(FoodRecipe.self) else {
                XCTFail("Unable to parse response after add recipe")
                return
            }


            let newRecipe = initialRecipe.copy(
                newName: RecipesTestData.newName,
                newDescription: RecipesTestData.newDescription,
                newProducts: [
                    RecipesTestData.newFirstProductItem,
                    RecipesTestData.newSecondProductItem
                ]
            )

            try app.test(.PUT, "/recipes") { inputRequest in
                try inputRequest.content.encode(newRecipe)
            } afterResponse: { modifyedRecipe in
                XCTAssertEqual(
                    modifyedRecipe.status,
                    .unauthorized,
                    "Ожидаемый статус: \(HTTPStatus.badRequest), полученный: \(modifyedRecipe.status)"
                )
            }
        }
    }

}
