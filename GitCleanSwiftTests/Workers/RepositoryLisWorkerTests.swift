//
//  RepositoryLisWorkerTests.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 07/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

@testable import GitCleanSwift
import XCTest

class RepositoryListsWorkerTests: XCTestCase
{
    //MARK: - Subject under test

    var repositoryListWorker: RepositoryListWorker!
  
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
        setupReposositoryListWorker()
    }

    override func tearDown()
    {
        super.tearDown()
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

    func setupReposositoryListWorker()
    {
        repositoryListWorker = RepositoryListWorker(repositoriesStore: RepositoryListStoreSpy())

    }

    // MARK: - Test doubles

    class RepositoryListStoreSpy: RepositoryStoreProtocol
    {
        // MARK: Method call expectations

        var fetchRepositoriesCalled = false

        func fetchRepositories(url: String, completionHandler: @escaping (RespositoriesResponse) -> Void) {
            fetchRepositoriesCalled = true

            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                completionHandler(RepositoryListsWorkerTests.testRepositoryResponse)
            }
        }
    }

    // MARK: - Tests

    func test_FetchRepositoriesShouldReturnListOfRepositories()
    {
        // Given
        let repositoryListStoreSpy = repositoryListWorker.repositoriesStore as! RepositoryListStoreSpy

        //When
        
        setupSucess()
        var pageFetched = ListPage<Repository>(items: [], page: "fakepage", hasNext: false)

        let expect = expectation(description: "Wait for fetchRepositories to return")
        repositoryListWorker.fetchRepositories(url: "fakeURL") { result in
            switch result {
            case .success(let page):
                pageFetched = page
                expect.fulfill()
            case .failure( _): break
            }
        }

        waitForExpectations(timeout: 1.2)

        let reposTest = try! RepositoryListsWorkerTests.testRepositoryResponse.get()

           // Then
        XCTAssert(repositoryListStoreSpy.fetchRepositoriesCalled, "Test if fetch is called")
        XCTAssertEqual(pageFetched.currentPage, "fakepage", "Test page")
        XCTAssertEqual(pageFetched.items.count, reposTest.items.count, "fetchRepositories() should return a list of pages, pages contain itens of repository")
        for repo in pageFetched.items {
            XCTAssert(reposTest.items.contains(repo), "Fetched repositories should be the same  ")
        }
    }


    func test_FetchRepositoriesShouldReturnError()
    {
        // Given
        let repositoryListStoreSpy = repositoryListWorker.repositoriesStore as! RepositoryListStoreSpy

        //When
        setupFail()
        var serviceErrorResult: ServiceError!
        let expect = expectation(description: "Wait for fetchRepositories() to return")
        repositoryListWorker.fetchRepositories(url: "fakeURL") { result in
            switch result {
            case .success( _): break
            case .failure( let error ):
                serviceErrorResult = error
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 1.2)

        var serviceErrorExpect: ServiceError!
        switch RepositoryListsWorkerTests.testRepositoryResponse {
        case .failure(let error):
            serviceErrorExpect = error
        case .success(_ ): break
        case .none: break
        }

           // Then
        XCTAssert(repositoryListStoreSpy.fetchRepositoriesCalled, "Test if fetch is called")
        XCTAssertEqual(serviceErrorExpect, serviceErrorResult, "Test error is the same type")

    }
}
