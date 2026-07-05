//
//  Item.swift
//  my-food-app-backend
//
//  Created by Nikolai Baklanov on 04.07.2026.
//


struct ProductItem: Codable {
    let nds, sum: Int
    let name: String
    let price: Int
    let quantity: Double
    let paymentType, productType, itemsQuantityMeasure: Int
    let labelCodeProcesMode, checkingProdInformationResult: Int?
}
