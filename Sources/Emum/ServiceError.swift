//
//  ServiceError.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation
enum ServiceError: Error, Equatable {
    case parse
    case urlInvalid
    case api(Error)

    static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        switch (lhs, rhs) {
        case (.urlInvalid, .urlInvalid):
            return true
        case (let .api(error1), let .api(error2)):
            return error1.localizedDescription == error2.localizedDescription
        case (.parse, .parse):
            return true
        default:
            return false
        }
    }
}
