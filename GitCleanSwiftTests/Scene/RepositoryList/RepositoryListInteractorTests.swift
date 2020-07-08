//
//  RepositoryListInteractorTests.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 07/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

@testable import GitCleanSwift
import XCTest

class RepositoryListInteractorTests: XCTestCase
{
    // MARK: - Subject under test

    var repositoryListInteractor: RepositoryListInteractor!
    
    static var testRepositoryResponse: Result<ListPage<Repository>, ServiceError>!
    //MARK: - Mock

    func getJsonMock() -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let filePath = testBundle.path(forResource: "RepositoryJsonMock", ofType: "txt")
            else { fatalError() }
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return jsonData
    }

    // MARK: - Test lifecycle

    override func setUp()
    {
        super.setUp()
        setupRepositoryListInteractor()
    }

    override func tearDown()
    {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupRepositoryListInteractor()
    {
        repositoryListInteractor = RepositoryListInteractor()
    }
    
    // MARK: - Test setup
    func setupSucess() {
        guard let colectionResponse = try? JSONDecoder().decode(ApiCollectionResponseCodable<Repository>.self, from: getJsonMock()) else {
            return XCTFail()
        }
        let listPageMock = ListPage(items: colectionResponse.items, page: "fakepage", hasNext: false)
        RepositoryListsWorkerTests.testRepositoryResponse = .success(listPageMock)
    }

    func setupFail() {
        RepositoryListsWorkerTests.testRepositoryResponse = .failure(.parse)
    }

    // MARK: - Test doubles

    class RepositoryListPresentationLogicSpy: RepositoryListPresentationLogic
    {
        // MARK: Method call expectations

        var presentRepositoriesCalled = false
        var presentLoadingCalled = false
        var presentErrorCalled = false

        // MARK: Spied methods
        func presentRepositories(response: RepositoryList.FetchRepositories.Response) {
            presentRepositoriesCalled = true
        }

        func presentLoading() {
            presentLoadingCalled = true
        }

        func presentError(response: RepositoryList.Error.Response) {
            presentErrorCalled = true
        }
    }

    class RepositoryListWorkerSpy: RepositoryListWorker
    {
        // MARK: Method call expectations

        var fetchRepositoryListCalled = false

        // MARK: Spied methods
        override func fetchRepositories(url: String, completionHandler: @escaping (RepositoryListWorker.RespositoriesResponse) -> Void) {
            fetchRepositoryListCalled = true
            completionHandler(RepositoryListsWorkerTests.testRepositoryResponse)
        }
    }

    // MARK: - Tests

    func test_FetchRepositoriesSucess()
    {
        // Given
        let repositoryListPresentationLogicSpy = RepositoryListPresentationLogicSpy()
        repositoryListInteractor.presenter = repositoryListPresentationLogicSpy

        let repositoryListWorkerSpy = RepositoryListWorkerSpy(repositoriesStore: RepositoryAPI())

        repositoryListInteractor.repositoryWorker = repositoryListWorkerSpy

        // When
        setupSucess()
        let request = RepositoryList.FetchRepositories.Request(isReloading: false)
        repositoryListInteractor.fetchRepositories(request: request)

        // Then
        XCTAssert(repositoryListWorkerSpy.fetchRepositoryListCalled)
        XCTAssert(repositoryListPresentationLogicSpy.presentLoadingCalled)
        XCTAssert(repositoryListPresentationLogicSpy.presentRepositoriesCalled)
    }

    func test_FetchRepositoriesError()
    {
        // Given
        let repositoryListPresentationLogicSpy = RepositoryListPresentationLogicSpy()
        repositoryListInteractor.presenter = repositoryListPresentationLogicSpy

        let repositoryListWorkerSpy = RepositoryListWorkerSpy(repositoriesStore: RepositoryAPI())

        repositoryListInteractor.repositoryWorker = repositoryListWorkerSpy

        // When
        setupFail()
        let request = RepositoryList.FetchRepositories.Request(isReloading: false)
        repositoryListInteractor.fetchRepositories(request: request)

        // Then
        XCTAssert(repositoryListWorkerSpy.fetchRepositoryListCalled)
        XCTAssert(repositoryListPresentationLogicSpy.presentLoadingCalled)
        XCTAssert(repositoryListPresentationLogicSpy.presentErrorCalled)
    }
}
