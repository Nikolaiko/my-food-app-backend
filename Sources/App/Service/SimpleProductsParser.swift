//
//  File.swift
//  my-food-app-backend
//
//  Created by Nikolai Baklanov on 04.07.2026.
//

import Foundation
import Model

struct SimpleProductsParser {
    private let appleNames = ["яблоко", "яблоки"]
    private let orangeNames = ["апельсин", "апельсины"]
    private let milkNames = ["молока", "молоко"]

    private let cottageCheeseNames = ["творог"]
    private let tomatoNames = ["томаты", "помидоры", "помидор", "томат"]
    private let cucumberNames = ["огурец", "огурцы"]
    private let potatoNames = ["картофель", "картошка"]
    private let bellPepperNames = ["перец"]
    private let sourCreamNames = ["сметана"]

    private let onionMainName = ["лук"]
    private let onionRedName = ["красный"]
    private let onionGreenName = ["зеленый"]


    func parseProductItem(item: ProductItem, date: String) -> FoodProduct {
        var parsedType: FoodProductType = .unknown
        let itemName = item.name.lowercased()

        if itemName.containsInList(appleNames) {
            parsedType = FoodProductType.apple
        } else if itemName.containsInList(orangeNames) {
            parsedType = FoodProductType.orange
        } else if (itemName.containsInList(milkNames)) {
            parsedType = FoodProductType.milk
        } else if (itemName.containsInList(cottageCheeseNames)) {
            parsedType = FoodProductType.cottage
        } else if (itemName.containsInList(tomatoNames)) {
            parsedType = FoodProductType.tomato
        } else if (itemName.containsInList(cucumberNames)) {
            parsedType = FoodProductType.cucumber
        } else if (itemName.containsInList(potatoNames)) {
            parsedType = FoodProductType.potato
        } else if (itemName.containsInList(bellPepperNames)) {
            parsedType = FoodProductType.bellpepper
        } else if (itemName.containsInList(onionMainName)) {
            if (itemName.containsInList(onionGreenName)) {
                parsedType = FoodProductType.greenOnion
            } else if (itemName.containsInList(onionRedName)) {
                parsedType = FoodProductType.redOnion
            } else {
                parsedType = FoodProductType.onions
            }
        } else if (itemName.containsInList(sourCreamNames)) {
            parsedType = FoodProductType.sourcream
        }

        return FoodProduct.init(
            id: UUID().uuidString,
            name: item.name,
            quantity: Float(ceil(item.quantity)),
            quantityType: .unknown,
            type: parsedType,
            date: date
        )
    }

    func purchaseDay(receiptDateTime: String?, qrRawString: String, now: Date = Date()) -> String {
        let receiptDay = receiptDateTime.flatMap { parseDay($0.prefix(10), format: "yyyy-MM-dd") }
        let qrDay = qrRawString
            .split(separator: "&")
            .first { $0.hasPrefix("t=") }
            .flatMap { parseDay($0.dropFirst(2).prefix(8), format: "yyyyMMdd") }
        return makeFormatter(format: "yyyy-MM-dd").string(from: receiptDay ?? qrDay ?? now)
    }

    private func parseDay(_ string: Substring, format: String) -> Date? {
        let formatter = makeFormatter(format: format)
        guard let date = formatter.date(from: String(string)), formatter.string(from: date) == string else {
            return nil
        }
        return date
    }

    private func makeFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter
    }
}
