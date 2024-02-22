import Foundation
import Fluent

struct CreateDBSchema: AsyncMigration {

    func prepare(on database: FluentKit.Database) async throws {
        
    }

    func revert(on database: FluentKit.Database) async throws {

    }
}
