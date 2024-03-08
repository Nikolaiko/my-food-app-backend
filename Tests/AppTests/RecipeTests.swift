@testable import App
import XCTVapor

final class AppTests: XCTestCase {

    func testGetAllRecipes() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try await app.autoRevert().get()
        try await app.autoMigrate().get()

        try app.test(.GET, "/recipes", afterResponse: { response in
            XCTAssertEqual(response.status, .ok)

            let recipes = try response.content.decode([FoodRecipeShortInfo].self)

            XCTAssertEqual(recipes.count, 1)
            //TODO: Проверить детальнее
        })
    }
}
