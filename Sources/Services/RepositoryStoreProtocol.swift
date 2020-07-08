//
//  RepositoryStoreProtocol.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

protocol RepositoryStoreProtocol {
    typealias RespositoriesResponse = Result<ListPage<Repository>, ServiceError>

    func fetchRepositories(url: String, completionHandler: @escaping (RespositoriesResponse) -> Void )
}
