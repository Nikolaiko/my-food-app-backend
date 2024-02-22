import Foundation
import Model
import Vapor

extension FoodRecipeProductEntry: Content {
    enum CodingKeys: String, CodingKey {
        case id
        case productType
        case count
        case quantityMeasure
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(count, forKey: .count)
        try container.encode(productType.rawValue, forKey: .productType)
        try container.encode(quantityMeasure.rawValue, forKey: .quantityMeasure)
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(String.self, forKey: .id)
        let count = try values.decode(Int.self, forKey: .count)

        let stringProductType = try values.decode(String.self, forKey: .productType)
        let productType = FoodProductType(rawValue: stringProductType)

        let intQuantityMeasure = try values.decode(Int.self, forKey: .quantityMeasure)
        let quantityMeasure = FoodQuantityType(rawValue: intQuantityMeasure)

        guard let productType, let quantityMeasure else { throw ParsingError.errorParsingEnumRawValue }

        self.init(id: id,
                  productType: productType,
                  count: count,
                  quantityMeasure: quantityMeasure)
    }
}
