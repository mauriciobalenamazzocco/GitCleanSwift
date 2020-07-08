//
//  UserStoreProtocol.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

protocol UserStoreProtocol {
    typealias UserResponse = Result<User?, ServiceError>
    func fetchUser(url: String, completionHandler: @escaping (UserResponse) -> Void ) -> RequestToken
}
