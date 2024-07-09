@testable import App

import XCTVapor
import Model

final class RecipeGetAllTests: XCTestCase {

    func testGetAllRecipes() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.GET, "/recipes", beforeRequest: { preRequest in
            preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
        }, afterResponse: { response in
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

    func testGetAllRecipesNotAuthError() async throws {
        let app = try await Application.testable()
        defer { app.shutdown() }

        try app.test(.GET, "/recipes", afterResponse: { response in
            XCTAssertEqual(
                response.status,
                .unauthorized,
                "Ожидаемый статус: \(HTTPStatus.badRequest), полученный: \(response.status)"
            )
        })
    }
}
