import Foundation
import XCTVapor
import App
import Model

extension Application {
  static func testable() async throws -> Application {
    let app = Application(.testing)
    try await configure(app)

    try await app.autoRevert().get()
    try await app.autoMigrate().get()

    return app
  }
}
