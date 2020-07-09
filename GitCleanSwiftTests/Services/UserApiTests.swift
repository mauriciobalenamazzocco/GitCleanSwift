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
        setupUserApiStore()
    }

    override func tearDown()
    {
        super.tearDown()
    }

    // MARK: - Test setup

    func setupSucess() {
        guard let user = try? JSONDecoder().decode(User.self, from: getJsonMock()) else {
            return XCTFail()
        }
        UserAPITests.testUserResponse = .success(user)
    }

    func setupFail(serviceError: ServiceError) {
        UserAPITests.testUserResponse = .failure(serviceError)
    }

    func setupUserApiStore()
    {
        userStoreProtocol = UserAPIMock()
    }

    // MARK: - Test doubles

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

    class UserAPIMock: UserAPI
    {
        // MARK: Method call expectations
        override func fetchUser(url: String, completionHandler: @escaping (UserAPI.UserResponse) -> Void) -> RequestToken {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                completionHandler(UserAPITests.testUserResponse)

            }
            return RequestToken(task: testURLSessionDataTaskSpy)
        }

    }

    // MARK: - Test

    func test_FetchUserShouldReturnUser()
    {
        // Given

        // When
        setupSucess()
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

        let userTest = try! UserAPITests.testUserResponse.get()

        // Then
        XCTAssertEqual(userFetched, userTest, "Test User")

    }

    func test_FetchUserShouldCancel()
    {
        // Given

        // When
        setupSucess()

        let requestToken = userStoreProtocol.fetchUser(url: "fakeURL") { _ in }

        let task = requestToken.task as? URLSessionDataTaskSpy
        requestToken.cancel()

        XCTAssert(task!.cancelCalled)
    }


    func test_FetchUserShouldReturnParseError()
    {
        // Given

        //When
        setupFail(serviceError: .parse)

        var serviceErrorResult: ServiceError!

        let expect = expectation(description: "Wait for fetchRepositories() to return")

        let _ = userStoreProtocol.fetchUser(url: "fakeURL") { result in
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

    func test_FetchUserShouldReturnUrlInvalidError()
    {
        // Given

        //When
        setupFail(serviceError: .urlInvalid)
        var serviceErrorResult: ServiceError!

        let expect = expectation(description: "Wait for fetchRepositories() to return")

        let _ = userStoreProtocol.fetchUser(url: "fakeURL") { result in
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

    func test_FetchUserShouldReturnApiError()
    {
        // Given
        //When
        setupFail(serviceError: .api(NSError(domain: "NOT FOUND", code: 404, userInfo: [:])))

        var serviceErrorResult: ServiceError!

        let expect = expectation(description: "Wait for fetchRepositories() to return")

        let _ = userStoreProtocol.fetchUser(url: "fakeURL") { result in
            switch result {
            case .success( _): break
            case .failure( let error ):
                serviceErrorResult = error
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 1.2)

        // Then
        XCTAssertEqual(.api(NSError(domain: "NOT FOUND", code: 404, userInfo: [:])), serviceErrorResult, "Test error is the same type")
    }
}
