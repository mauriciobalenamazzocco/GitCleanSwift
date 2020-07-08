//
//  Owner.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 04/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

struct Owner: Codable {
    var url: String?
    var avatarUrl: String?
}

extension Owner {
    enum CodingKeys: String, CodingKey {
        case url = "url"
        case avatarUrl = "avatar_url"
    }
}

extension Owner: Equatable {
    public static func == (lhs: Owner, rhs: Owner) -> Bool {
        return lhs.url == rhs.url
            && lhs.avatarUrl == rhs.avatarUrl
    }
}
