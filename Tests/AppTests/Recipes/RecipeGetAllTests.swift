@testable import App

import XCTVapor
import Model

final class RecipeGetAllTests: XCTestCase {

    func testGetAllRecipes() async throws {
        try await Application.withTestable { app in
            try await app.test(.GET, "/recipes") { preRequest async throws in
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)

                let recipes = try response.content.decode([FoodRecipeShortInfo].self)
                XCTAssertEqual(recipes.count, 1)
                let initialRecipe = try XCTUnwrap(recipes.first)

                XCTAssertEqual(initialRecipe.name, InitialDBData.recipeOneName)
                XCTAssertEqual(initialRecipe.shortDescription, InitialDBData.recipeOneShortDescription)
                XCTAssertTrue(initialRecipe.tags.isEmpty)
                XCTAssertNil(initialRecipe.proteins)
                XCTAssertNil(initialRecipe.fats)
                XCTAssertNil(initialRecipe.carbohydrates)
                XCTAssertNil(initialRecipe.calories)
            }
        }
    }

    func testGetAllRecipesNotAuthError() async throws {
        try await Application.withTestable { app in
            try await app.test(.GET, "/recipes") { response async throws in
                XCTAssertEqual(response.status, .unauthorized)
            }
        }
    }
}
