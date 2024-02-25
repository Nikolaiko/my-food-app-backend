import Foundation
import Vapor

struct FoodRecipeShortInfo: Content {
    let id: String
    let name: String
    let shortDescription: String
    let tags: [Int]
}
