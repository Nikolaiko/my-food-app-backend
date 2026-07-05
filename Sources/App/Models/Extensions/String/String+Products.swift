//
//  File.swift
//  my-food-app-backend
//
//  Created by Nikolai Baklanov on 04.07.2026.
//

import Foundation

extension String {
    func containsInList(_ productNames: [String]) -> Bool {
        return productNames.first { self.contains($0) } != nil
    }
}
