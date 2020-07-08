//
//  RepositoryApiTests.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 07/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

@testable import GitCleanSwift
import XCTest

class RepositoryAPITests: XCTestCase
{
    // MARK: - Subject under test

    var repositoryStoreProtocol: RepositoryStoreProtocol!
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
        setupRepositoryApiStore()
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
        RepositoryAPITests.testRepositoryResponse = .success(listPageMock)
    }

    func setupFail() {
        RepositoryAPITests.testRepositoryResponse = .failure(.parse)
    }

    func setupRepositoryApiStore()
    {
        repositoryStoreProtocol = RepositoryAPISpy()
    }

    // MARK: - Test doubles

      class RepositoryAPISpy: RepositoryAPI
      {
          // MARK: Method call expectations
          override func fetchRepositories(url: String, completionHandler: @escaping (RespositoriesResponse) -> Void) {

              DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                  completionHandler(RepositoryAPITests.testRepositoryResponse)
              }
          }
      }

    // MARK: - Test

    func testFetchRepositoriesShouldReturnListOfRepositories()
    {
        // Given

        // When
        setupSucess()
        var pageFetched = ListPage<Repository>(items: [], page: "fakepage", hasNext: false)

        let expect = expectation(description: "Wait for fetchRepositories to return")

        repositoryStoreProtocol.fetchRepositories(url: "fakeURL") { result in
            switch result {
            case .success(let page):
                pageFetched = page
                expect.fulfill()
            case .failure( _): break
            }
        }

        waitForExpectations(timeout: 1.2)

        let reposTest = try! RepositoryAPITests.testRepositoryResponse.get()

        // Then
        XCTAssertEqual(pageFetched.currentPage, "fakepage", "Test page")
        XCTAssertEqual(pageFetched.items.count, reposTest.items.count, "fetchRepositories() should return a list of pages, pages contain itens of repository")
        for repo in pageFetched.items {
            XCTAssert(reposTest.items.contains(repo), "Fetched repositories should be the same  ")
        }
    }

    func testFetchRepositoriesShouldReturnError()
    {
        // Given
        //When
        setupFail()
        var serviceErrorResult: ServiceError!
        let expect = expectation(description: "Wait for fetchRepositories() to return")
        repositoryStoreProtocol.fetchRepositories(url: "fakeURL") { result in
            switch result {
            case .success( _): break
            case .failure( let error ):
                serviceErrorResult = error
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 1.2)

        var serviceErrorExpect: ServiceError!
        switch RepositoryAPITests.testRepositoryResponse {
        case .failure(let error):
            serviceErrorExpect = error
        case .success(_ ): break
        case .none: break
        }

        // Then
        XCTAssertEqual(serviceErrorExpect, serviceErrorResult, "Test error is the same type")
    }
}
