import Foundation
import XCTVapor
@testable import App
import Model

extension Application {
  static func testable() async throws -> Application {
    let app = try await Application.make(.testing)
    do {
      try await configure(app)

      try await app.autoRevert().get()
      try await app.autoMigrate().get()
    } catch {
      try? await app.asyncShutdown()
      throw error
    }

    return app
  }

  static func withTestable(_ test: (Application) async throws -> Void) async throws {
    let app = try await testable()
    do {
      try await test(app)
    } catch {
      try? await app.asyncShutdown()
      throw error
    }
    try await app.asyncShutdown()
  }

  func addRecipe(_ recipe: NewFoodRecipe) async throws -> FoodRecipe {
    var addedRecipe: FoodRecipe?
    try await test(.POST, "/recipes/add") { preRequest async throws in
      try preRequest.content.encode(recipe)
      preRequest.headers.add(name: authHeaderName, value: headerAuthValue)
    } afterResponse: { addResponse async throws in
      XCTAssertEqual(addResponse.status, .ok)
      addedRecipe = try addResponse.content.decode(FoodRecipe.self)
    }
    return try XCTUnwrap(addedRecipe)
  }
}
