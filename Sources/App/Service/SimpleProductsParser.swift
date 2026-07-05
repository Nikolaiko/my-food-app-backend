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


    func parseProductItem(item: ProductItem) -> FoodProduct {
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
            quantity: Int(ceil(item.quantity)),
            quantityType: .unknown,
            type: parsedType,
            date: Date()
        )
    }
}
