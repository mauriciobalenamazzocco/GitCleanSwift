//
//  UserApiTests.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 07/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

@testable import GitCleanSwift
import XCTest

class UserAPITests: XCTestCase
{
    // MARK: - Subject under test

    var userStoreProtocol: UserStoreProtocol!

    static var testUserResponse: Result<User?, ServiceError>!

    static var testURLSessionDataTaskSpy = URLSessionDataTaskSpy()

    //MARK: - Mock

    func getJsonMock() -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let filePath = testBundle.path(forResource: "UserJsonMock", ofType: "txt")
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

    // MARK: - Test doubles

    class URLSessionMock: URLSessionProtocol {
        var data: Data?
        var error: Error?
        var urlResponse: URLResponse?

        func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            completionHandler(data, urlResponse, error)
            return  URLSessionDataTaskSpy()
        }
    }

    class UserAPIMock: UserAPI
    {
        // MARK: Method call expectations
        override func fetchUser(url: String, completionHandler: @escaping (UserAPI.UserResponse) -> Void) -> RequestToken {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {

                if let _ = NSURL(string: url) {
                    completionHandler(.failure(.urlInvalid))
                }

                completionHandler(UserAPITests.testUserResponse)

            }
            return RequestToken(task: testURLSessionDataTaskSpy)
        }

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


    // MARK: - Test

    func test_FetchUserShouldReturnUser()
    {
        // Given
        let urlSessionMock = URLSessionMock()
        urlSessionMock.data = getJsonMock()


        // When

        userStoreProtocol =  UserAPI(urlSession: urlSessionMock)

        var userFetched: User!

        let expect = expectation(description: "Wait for fetchRepositories to return")

        let _ = userStoreProtocol.fetchUser(url: "fakeURL") { result in
            switch result {
            case .success(let user):
                userFetched = user
                expect.fulfill()
            case .failure( _): break
            }
        }

        waitForExpectations(timeout: 1.2)

    

        // Then
        XCTAssert(userFetched != nil, "Test User")

    }

    func test_FetchUserShouldCancel()
    {
        // Given
        guard let user = try? JSONDecoder().decode(User.self, from: getJsonMock()) else {
            return XCTFail()
        }

        UserAPITests.testUserResponse = .success(user)
        // When

        userStoreProtocol =  UserAPIMock()
        let requestToken = userStoreProtocol.fetchUser(url: "http://gmail.com.br") { _ in }

        let task = requestToken.task as? URLSessionDataTaskSpy
        requestToken.cancel()

        XCTAssert(task!.cancelCalled)
    }

    
    func test_FetchUserShouldReturnParseError()
    {
        // Given
        let urlSessionMock = URLSessionMock()
        urlSessionMock.data = Data()

        //When
        userStoreProtocol =  UserAPI(urlSession: urlSessionMock)

        var serviceErrorResult: ServiceError!

        let expect = expectation(description: "Wait for fetchRepositories() to return")

        let _ = userStoreProtocol.fetchUser(url: "url") { result in
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

    func test_FetchUserShouldReturnInvalidUrlError()
       {
           // Given
           let urlSessionMock = URLSessionMock()


           //When
           userStoreProtocol =  UserAPI(urlSession: urlSessionMock)

           var serviceErrorResult: ServiceError!

           let expect = expectation(description: "Wait for fetchRepositories() to return")

           let _ = userStoreProtocol.fetchUser(url: "<") { result in
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


}
