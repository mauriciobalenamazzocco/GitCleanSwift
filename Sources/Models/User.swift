//
//  User.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 04/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

struct User: Codable {
    var name: String?
    var avatarUrl: String?
    var login: String?
}

extension User {
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case avatarUrl = "avatar_url"
        case login = "login"
    }
}
extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.name == rhs.name
            && lhs.avatarUrl == rhs.avatarUrl
            && lhs.login == rhs.login
    }
}
