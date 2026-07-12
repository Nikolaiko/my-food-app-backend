import Foundation
@preconcurrency import Model

enum InitialDBData {
    static let recipeOneName = "Овощной салат"
    static let recipeOneDescription = "Очень вкусное и простое, классическое блюдо"
    static let recipeOneShortDescription = "Попсовый салат"

    static let initialTomatoCount = Float(4.0)
    static let initialTomatoQuantityType = FoodQuantityType.item

    static let initialCucmberCount = Float(1.0)
    static let initialCucmberQuantityType = FoodQuantityType.item

    static let initialCreamCount = Float(300.0)
    static let initialCreamQuantityType = FoodQuantityType.weight

}

