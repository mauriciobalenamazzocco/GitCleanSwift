//
//  RepositoryListPresenter.swift
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

protocol RepositoryListPresentationLogic {
    func presentRepositories(response: RepositoryList.FetchRepositories.Response)
    func presentLoading()
    func presentError(response: RepositoryList.Error.Response)
}

class RepositoryListPresenter: RepositoryListPresentationLogic {

    weak var viewController: RepositoryListDisplayLogic?

    // MARK: presentRepositories
    func presentRepositories(response: RepositoryList.FetchRepositories.Response) {
        let repositories: [RepositoryList.FetchRepositories.ViewModel.DisplayedRepository] =
            response.repositories.map { repo -> RepositoryList.FetchRepositories.ViewModel.DisplayedRepository in
                return RepositoryList.FetchRepositories.ViewModel.DisplayedRepository(
                    repoName: Helper.app.formatRepositoryText(repositoryName: repo.name),
                    userAvatarPath: repo.owner?.avatarUrl,
                    repoStarsCount: Helper.app.formatStarText(starsCount: repo.starsCount ?? 0),
                    userProfilePath: repo.owner?.url
                )
            }
        let viewModel = RepositoryList.FetchRepositories.ViewModel(displayedRepositories: repositories,
                                                                   isReloading: response.isReloading,
                                                                   hasNext: response.hasNext)
        viewController?.displayRepositories(viewModel: viewModel)
    }

    func presentLoading() {
        viewController?.displayLoading()
    }

    func presentError(response: RepositoryList.Error.Response) {
        var errorString: String
        switch response.serviceError {
        case .api(let error):
            errorString = error.localizedDescription
        case .parse:
            errorString = NSLocalizedString("apiErrorLimit", comment: "")
        case .urlInvalid:
            errorString = NSLocalizedString("invalidUrl", comment: "")
        }
        let model = RepositoryList.Error.ViewModel(errorString: errorString)

        viewController?.displayError(viewModel: model)

    }
}
