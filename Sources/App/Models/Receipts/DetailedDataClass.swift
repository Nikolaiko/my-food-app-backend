//
//  DataClass.swift
//  my-food-app-backend
//
//  Created by Nikolai Baklanov on 04.07.2026.
//


struct DetailedDataClass: Codable {
    let dataJSON: JSONInformation

    enum CodingKeys: String, CodingKey {
        case dataJSON = "json"
    }
}
