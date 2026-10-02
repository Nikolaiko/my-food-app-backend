@testable import App

import XCTVapor
import Model

final class RecipeModifyTests: XCTestCase {

    func testModifyById() async throws {
        try await Application.withTestable { app in
            let initialRecipe = try await app.addRecipe(RecipesTestData.testRecipe)
            let update = recipeUpdate(id: initialRecipe.id)

            var modifiedRecipe: FoodRecipe?
            try await app.test(.PUT, "/recipes") { preRequest async throws in
                try preRequest.content.encode(update)
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)
                modifiedRecipe = try response.content.decode(FoodRecipe.self)
            }
            let recipe = try XCTUnwrap(modifiedRecipe)

            XCTAssertEqual(recipe.id, initialRecipe.id)
            XCTAssertEqual(recipe.name, RecipesTestData.newName)
            XCTAssertEqual(recipe.description, RecipesTestData.newDescription)
            XCTAssertEqual(recipe.tags, RecipesTestData.newTags)
            XCTAssertEqual(recipe.proteins, RecipesTestData.newProteins)
            XCTAssertNil(recipe.fats)
            XCTAssertNil(recipe.carbohydrates)
            XCTAssertEqual(recipe.calories, RecipesTestData.newCalories)
            XCTAssertEqual(recipe.products.count, RecipesTestData.newProductsCount)
            XCTAssertEqual(
                Set(recipe.products.map(\.productType)),
                [RecipesTestData.newFirstProductItem.productType, RecipesTestData.newSecondProductItem.productType]
            )
            XCTAssertFalse(recipe.products.contains { $0.id.isEmpty })

            try await app.test(.GET, "/recipes/\(initialRecipe.id)") { preRequest async throws in
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .ok)

                let savedRecipe = try response.content.decode(FoodRecipe.self)
                XCTAssertEqual(savedRecipe.name, RecipesTestData.newName)
                XCTAssertEqual(savedRecipe.proteins, RecipesTestData.newProteins)
                XCTAssertNil(savedRecipe.fats)
                XCTAssertEqual(Set(savedRecipe.products.map(\.id)), Set(recipe.products.map(\.id)))
            }
        }
    }

    func testModifyRecipeNotFoundError() async throws {
        try await Application.withTestable { app in
            try await app.test(.PUT, "/recipes") { preRequest async throws in
                try preRequest.content.encode(recipeUpdate(id: RecipesTestData.notExistingUUID))
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .notFound)
            }
        }
    }

    func testModifyRecipeBadRequestError() async throws {
        try await Application.withTestable { app in
            try await app.test(.PUT, "/recipes") { preRequest async throws in
                try preRequest.content.encode(RecipesTestData.testDummyEntity)
                preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .badRequest)
            }
        }
    }

    func testModifyByIdAuthError() async throws {
        try await Application.withTestable { app in
            let initialRecipe = try await app.addRecipe(RecipesTestData.testRecipe)

            try await app.test(.PUT, "/recipes") { preRequest async throws in
                try preRequest.content.encode(recipeUpdate(id: initialRecipe.id))
            } afterResponse: { response async throws in
                XCTAssertEqual(response.status, .unauthorized)
            }
        }
    }

    private func recipeUpdate(id: String) -> FoodRecipeUpdate {
        FoodRecipeUpdate(
            id: id,
            name: RecipesTestData.newName,
            shortDescription: RecipesTestData.testRecipe.shortDescription,
            description: RecipesTestData.newDescription,
            products: [
                RecipesTestData.newFirstProductItem,
                RecipesTestData.newSecondProductItem
            ],
            tags: RecipesTestData.newTags,
            proteins: RecipesTestData.newProteins,
            fats: nil,
            carbohydrates: nil,
            calories: RecipesTestData.newCalories
        )
    }
}
