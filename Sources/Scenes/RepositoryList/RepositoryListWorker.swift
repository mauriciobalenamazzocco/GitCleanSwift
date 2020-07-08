//
//  RepositoryListWorker.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright (c) 2020 Mauricio Balena Mazzocco. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

class RepositoryListWorker: RepositoryStoreProtocol {
    var repositoriesStore: RepositoryStoreProtocol

    init(repositoriesStore: RepositoryStoreProtocol) {
        self.repositoriesStore = repositoriesStore
    }

    func fetchRepositories(url: String, completionHandler: @escaping (
        RespositoriesResponse) -> Void) {
        repositoriesStore.fetchRepositories(url: url) { result in
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }
}
