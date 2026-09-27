import Foundation
import Testing
import Model

struct FoodRecipeQuantitiesTests {
    @Test func decodesSeveralQuantities() throws {
        let json = """
        {"id": "1", "productType": "Tomato", "quantities": [{"count": 4, "quantityMeasure": 3}, {"count": 500, "quantityMeasure": 1}]}
        """
        let entry = try JSONDecoder().decode(FoodRecipeProductEntry.self, from: Data(json.utf8))
        #expect(entry.quantities.map(\.count) == [4, 500])
        #expect(entry.quantities.map(\.quantityMeasure) == [.item, .weight])
    }

    @Test func encodesQuantitiesAsArray() throws {
        let entry = FoodRecipeProductEntry(id: "1", productType: .sourcream, quantities: [FoodRecipeQuantity(count: 300, quantityMeasure: .weight)])
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = String(decoding: try encoder.encode(entry), as: UTF8.self)
        #expect(json == #"{"id":"1","productType":"Sourcream","quantities":[{"count":300,"quantityMeasure":1}]}"#)
    }
}
