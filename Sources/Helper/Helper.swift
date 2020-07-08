//
//  Helper.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 07/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

class Helper {
    static var app: Helper = {
        return Helper()
    }()

    func formatRepositoryText(repositoryName: String?) -> String {
        return " \(repositoryName ?? "") "
    }

    //Like github Format
    func formatStarText(starsCount: Int64) -> String {
        if starsCount > 1000 {
            let convertedValue: Double = Double(starsCount) / 1000
            let format = String(format: "%2.1f", convertedValue)
            let doubleFormat = Double(format)
            let isInteger = floor(doubleFormat ?? 0) == doubleFormat
            if isInteger {
                return " • ⭐️\(Int(convertedValue.rounded()))k "
            } else {
                return  " • ⭐️\(format)k"
            }
        }
        return  " • ⭐️\(starsCount)"
    }
}
