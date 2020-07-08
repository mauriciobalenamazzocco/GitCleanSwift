//
//  Repository.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 04/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

struct Repository: Codable {
    var name: String?
    var starsCount: Int64?
    var owner: Owner?
}

extension Repository {
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case starsCount = "stargazers_count"
        case owner = "owner"
    }
}

extension Repository: Equatable {
    public static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.name == rhs.name
            && lhs.starsCount == rhs.starsCount
            && lhs.owner == rhs.owner
    }
}
