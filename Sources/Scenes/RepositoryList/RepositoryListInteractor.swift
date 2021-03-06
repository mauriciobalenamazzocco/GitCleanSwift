//
//  RepositoryListInteractor.swift
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

protocol RepositoryListBusinessLogic {
  func fetchRepositories(request: RepositoryList.FetchRepositories.Request)
}

protocol RepositoryListDataStore {}

class RepositoryListInteractor: RepositoryListBusinessLogic, RepositoryListDataStore {
    var presenter: RepositoryListPresentationLogic?
    var repositoryWorker = RepositoryListWorker(repositoriesStore: RepositoryAPI())

    private var listPage: ListPage<Repository> = ListPage.first(items: [],
                                                                page: RepositoryAPI.apiRepositoryPath,
                                                                hasNext: false)

    // MARK: fetchRepositories
    func fetchRepositories(request: RepositoryList.FetchRepositories.Request) {

        if request.isReloading {
            listPage = ListPage.first(items: [],
                                      page: RepositoryAPI.apiRepositoryPath,
                                      hasNext: false)
        } else if listPage.items.isEmpty {
            presenter?.presentLoading()
        }

        repositoryWorker.fetchRepositories(url: listPage.currentPage) { [weak self ] result in
            guard let self = self else { return }

            switch result {
            case .success(let page):
                self.listPage = self.listPage.with(nextPage: page)
                let reponse = RepositoryList.FetchRepositories.Response(
                    repositories: page.items,
                    hasNext: page.hasNext,
                    isReloading: request.isReloading
                )
                self.presenter?.presentRepositories(response: reponse)
            case .failure(let error):
                self.presenter?.presentError(response: RepositoryList.Error.Response(serviceError: error))
            }
        }
    }
}
