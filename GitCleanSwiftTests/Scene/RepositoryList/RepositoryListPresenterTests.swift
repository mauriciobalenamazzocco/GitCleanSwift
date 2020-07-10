//
//  RepositoryListPresenterTests.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 07/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

@testable import GitCleanSwift
import XCTest

class RepositoryListPresenterTests: XCTestCase
{
    // MARK: - Subject under test

    var repositoryListPresenter: RepositoryListPresenter!

    //MARK: - Mock
    func getJsonMock() -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let filePath = testBundle.path(forResource: "RepositoryJsonMock", ofType: "txt")
            else { fatalError() }
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return jsonData
    }

    private var repositoriesMock: [Repository] = []

    // MARK: - Test lifecycle

    override func setUp()
    {
        super.setUp()
        setupRepositoriesMock()
        setupRepositoryListPresenter()
    }

    override func tearDown()
    {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupRepositoriesMock(){
        guard let colectionResponse = try? JSONDecoder().decode(ApiCollectionResponseCodable<Repository>.self, from: getJsonMock()) else {
            return XCTFail()
        }
        let page = ListPage(items: colectionResponse.items, page: "fakepage", hasNext: false)
        repositoriesMock =  page.items
    }

    func setupRepositoryListPresenter()
    {
        repositoryListPresenter = RepositoryListPresenter()
    }

    // MARK: - Test doubles

    class RepositoryListDisplayLogicSpy: RepositoryListDisplayLogic
    {
        // MARK: Method call expectations

        var displayFetchedRepositoriesCalled = false
        var displayLoadingCalled = false
        var displayErrorCalled = false

        // MARK: Argument expectations

        var fetchRepositoriesViewModel: RepositoryList.FetchRepositories.ViewModel!

        var errorViewModel: RepositoryList.Error.ViewModel!

        // MARK: Spied methods
        func displayRepositories(viewModel: RepositoryList.FetchRepositories.ViewModel) {
            displayFetchedRepositoriesCalled = true
            self.fetchRepositoriesViewModel = viewModel
        }

        func displayLoading() {
            displayLoadingCalled = true
        }

        func displayError(viewModel: RepositoryList.Error.ViewModel) {
            displayErrorCalled = true
            errorViewModel = viewModel
        }
    }

    // MARK: - Tests
    func test_FetchRepoisitoryCalled()
    {
        // Given
        let repositoryListDisplayLogicSpy = RepositoryListDisplayLogicSpy()
        repositoryListPresenter.viewController = repositoryListDisplayLogicSpy

        // When
        let response = RepositoryList.FetchRepositories.Response(repositories: repositoriesMock, hasNext: false, isReloading: false)
        repositoryListPresenter.presentRepositories(response: response)

        // Then
        XCTAssert(repositoryListDisplayLogicSpy.displayFetchedRepositoriesCalled)
    }

    func test_RepositoryCorrectFormat()
    {
        // Given
        let repositoryListDisplayLogicSpy = RepositoryListDisplayLogicSpy()
        repositoryListPresenter.viewController = repositoryListDisplayLogicSpy

        // When

        let response = RepositoryList.FetchRepositories.Response(repositories: repositoriesMock, hasNext: false, isReloading: false)
        repositoryListPresenter.presentRepositories(response: response)


        // Then
        let displayedRepositories = repositoryListDisplayLogicSpy.fetchRepositoriesViewModel.displayedRepositories


        let repository = displayedRepositories.first

        XCTAssertEqual(repository?.repoName, " awesome-ios ")
        XCTAssertEqual(repository?.userAvatarPath, "https://avatars2.githubusercontent.com/u/484656?v=4")
        XCTAssertEqual(repository?.repoStarsCount," • ⭐️35.2k")
        XCTAssertEqual(repository?.userProfilePath,"https://api.github.com/users/vsouza")
    }


    func test_RepositoryStarsFormatLessThenThousand()
    {
        // Given
        let repositoryListDisplayLogicSpy = RepositoryListDisplayLogicSpy()
        repositoryListPresenter.viewController = repositoryListDisplayLogicSpy

        // When

        let testRepository = Repository(name: "name", starsCount: 900, owner: Owner(url: "", avatarUrl: ""))
        let response = RepositoryList.FetchRepositories.Response(repositories: [testRepository], hasNext: false, isReloading: false)
        repositoryListPresenter.presentRepositories(response: response)



        let displayedRepositories = repositoryListDisplayLogicSpy.fetchRepositoriesViewModel.displayedRepositories


        let repository = displayedRepositories.first

        // Then

        XCTAssertEqual(repository?.repoStarsCount," • ⭐️900")
        
    }

    func test_ShouldReturnErrorTypeParse()
    {
        // Given
        let repositoryListDisplayLogicSpy = RepositoryListDisplayLogicSpy()
        repositoryListPresenter.viewController = repositoryListDisplayLogicSpy

        // When
        let response = RepositoryList.Error.Response(serviceError: .parse)
        repositoryListPresenter.presentError(response: response)

        // Then
        XCTAssertEqual(repositoryListDisplayLogicSpy.errorViewModel.errorString, NSLocalizedString("apiErrorLimit", comment: ""))
    }

    func test_ShouldReturnErrorTypeURL()
    {
        // Given
        let repositoryListDisplayLogicSpy = RepositoryListDisplayLogicSpy()
        repositoryListPresenter.viewController = repositoryListDisplayLogicSpy

        // When
        let response = RepositoryList.Error.Response(serviceError: .urlInvalid)
        repositoryListPresenter.presentError(response: response)

        // Then
        XCTAssertEqual(repositoryListDisplayLogicSpy.errorViewModel.errorString, NSLocalizedString("invalidUrl", comment: ""))
    }

    func test_ShouldReturnErrorTypeApiError()
      {
          // Given
          let repositoryListDisplayLogicSpy = RepositoryListDisplayLogicSpy()
          repositoryListPresenter.viewController = repositoryListDisplayLogicSpy

          // When
        let response = RepositoryList.Error.Response(serviceError: .api(NSError(domain: "Error 404", code: 404, userInfo: [:])))
          repositoryListPresenter.presentError(response: response)

          // Then
        let errorExpected =  NSError(domain: "Error 404", code: 404, userInfo: [:])
        XCTAssertEqual(repositoryListDisplayLogicSpy.errorViewModel.errorString ,errorExpected.localizedDescription)
      }


    func test_ShouldReturnErrorCalled()
    {
        // Given
        let repositoryListDisplayLogicSpy = RepositoryListDisplayLogicSpy()
        repositoryListPresenter.viewController = repositoryListDisplayLogicSpy

        // When
        let response = RepositoryList.Error.Response(serviceError: .parse)
        repositoryListPresenter.presentError(response: response)

        // Then
        XCTAssert(repositoryListDisplayLogicSpy.displayErrorCalled)
    }
}
