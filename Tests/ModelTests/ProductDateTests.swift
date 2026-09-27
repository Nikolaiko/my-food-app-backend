import Foundation
import Testing
import Model

struct FoodProductDateTests {
    @Test func encodesDateAsDayString() throws {
        let product = FoodProduct(id: "1", name: "Томаты черри 250г", quantity: 1, quantityType: .packed, type: .tomato, date: "2026-07-12")
        let json = String(decoding: try JSONEncoder().encode(product), as: UTF8.self)
        #expect(json.contains(#""date":"2026-07-12""#))
    }

    @Test func decodesDayString() throws {
        let json = """
        {"id": "1", "name": "Молоко", "quantity": 1, "quantityType": 4, "type": "Milk", "date": "2026-07-12"}
        """
        let product = try JSONDecoder().decode(FoodProduct.self, from: Data(json.utf8))
        #expect(product.date == "2026-07-12")
    }
}
