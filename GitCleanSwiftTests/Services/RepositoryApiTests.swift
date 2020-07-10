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
    }

    override func tearDown()
    {
        super.tearDown()
    }

    class URLSessionDataTaskSpy: URLSessionDataTask {
        var cancelCalled = false
        var resumeCalled = false
        override init () {}

        override func cancel() {
            cancelCalled = true
        }

        override func resume() {
            resumeCalled = true
        }
    }



    class URLSessionMock: URLSessionProtocol {
        var data: Data?
        var error: Error?
        var urlResponse: URLResponse?

        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            completionHandler(data, urlResponse, error)
            return  URLSessionDataTaskSpy()
        }
    }

    // MARK: - Test

    func test_FetchRepositoriesShouldReturnListOfRepositories()
    {
        // Given
        let urlSessionMock = URLSessionMock()
        urlSessionMock.data = getJsonMock()
        urlSessionMock.urlResponse = HTTPURLResponse(
            url: URL(string: RepositoryAPI.apiRepositoryPath )!,
            statusCode: 200 ,
            httpVersion: "",
            headerFields: ["Link":"<https://api.github.com/search/repositories?q=language%3Aswift&sort=stars&page=2>;rel=\'next\', <https://api.github.com/search/repositories?q=language%3Aswift&sort=stars&page=34>; rel=\'last\'"])

        // When

        repositoryStoreProtocol =  RepositoryAPI(urlSession: urlSessionMock)


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

        // Then
        XCTAssertEqual(pageFetched.currentPage, "https://api.github.com/search/repositories?q=language%3Aswift&sort=stars&page=2", "Test page")
        XCTAssertEqual(pageFetched.items.count, 30, "fetchRepositories() should return a list of pages, pages contain itens of repository")

    }

    func test_fetchRepositoriesShouldReturnShouldReturnHeaderFieldsParseError()
    {
        // Given
        let urlSessionMock = URLSessionMock()
        urlSessionMock.data = getJsonMock()
        urlSessionMock.urlResponse = HTTPURLResponse(
            url: URL(string: RepositoryAPI.apiRepositoryPath )!,
            statusCode: 200 ,
            httpVersion: "",
            headerFields: ["Link":"Link broken"])

        // When

        repositoryStoreProtocol =  RepositoryAPI(urlSession: urlSessionMock)


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

        // Then
        XCTAssertEqual(.parse, serviceErrorResult, "Test error is the same type")
    }

    func test_FetchRepositoriesShouldReturnParseError()
    {
        // Given
        let urlSessionMock = URLSessionMock()
        urlSessionMock.data = Data()

        //When
        repositoryStoreProtocol =  RepositoryAPI(urlSession: urlSessionMock)

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

        // Then
        XCTAssertEqual(.parse, serviceErrorResult, "Test error is the same type")
    }

    func test_FetchRepositoriesShouldReturnInvalidUrl()
    {
        // Given
        let urlSessionMock = URLSessionMock()

        //When
        repositoryStoreProtocol =  RepositoryAPI(urlSession: urlSessionMock)

        var serviceErrorResult: ServiceError!
        let expect = expectation(description: "Wait for fetchRepositories() to return")
        repositoryStoreProtocol.fetchRepositories(url: "<") { result in
            switch result {
            case .success( _): break
            case .failure( let error ):
                serviceErrorResult = error
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 1.2)

        // Then
        XCTAssertEqual(.urlInvalid, serviceErrorResult, "Test error is the same type")
    }

    func test_FetchRepositoriesShouldReturnParseHtttpResponseError()
    {
        // Given
        let urlSessionMock = URLSessionMock()
        urlSessionMock.data = getJsonMock()

        //When
        repositoryStoreProtocol =  RepositoryAPI(urlSession: urlSessionMock)

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

        // Then
        XCTAssertEqual(.parse, serviceErrorResult, "Test error is the same type")
    }

    func test_FetchRepositoriesShouldReturnApiError()
    {
        // Given
        let urlSessionMock = URLSessionMock()
        urlSessionMock.error = NSError(domain: "Error 404", code: 404, userInfo: [:])

        //When
        repositoryStoreProtocol =  RepositoryAPI(urlSession: urlSessionMock)

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

        // Then
        XCTAssertEqual(.api(NSError(domain: "Error 404", code: 404, userInfo: [:])), serviceErrorResult, "Test error is the same type")
    }
}
