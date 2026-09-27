import Foundation
import Testing

enum ReceiptsTestData {
    static let qrWithTime = "t=20240117T1126&s=1396.33&fn=7284440700349606&i=52208&fp=1476279607&n=1"
    static let qrWithoutTime = "s=1396.33&fn=7284440700349606&i=52208&fp=1476279607&n=1"

    static func json(named name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
        return try Data(contentsOf: url)
    }
}
