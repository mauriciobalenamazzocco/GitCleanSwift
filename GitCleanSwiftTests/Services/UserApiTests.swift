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

    func setupFail() {
        UserAPITests.testUserResponse = .failure(.parse)
    }

    func setupUserApiStore()
    {
        userStoreProtocol = UserAPIMock()
    }

    // MARK: - Test doubles

    class UserAPIMock: UserAPI
    {
        // MARK: Method call expectations
        override func fetchUser(url: String, completionHandler: @escaping (UserAPI.UserResponse) -> Void) -> RequestToken {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                completionHandler(UserAPITests.testUserResponse)

            }
               return RequestToken(task: nil)
        }

    }

    // MARK: - Test

    func testFetchRepositoriesShouldReturnListOfRepositories()
    {
        // Given

        // When
        setupSucess()
        var userFetched: User!

        let expect = expectation(description: "Wait for fetchRepositories to return")

        userStoreProtocol.fetchUser(url: "fakeURL") { result in
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

    func testFetchUserShouldReturnError()
    {
        // Given

        //When
        setupFail()
        var serviceErrorResult: ServiceError!

        let expect = expectation(description: "Wait for fetchRepositories() to return")

        userStoreProtocol.fetchUser(url: "fakeURL") { result in
            switch result {
            case .success( _): break
            case .failure( let error ):
                serviceErrorResult = error
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 1.2)

        var serviceErrorExpect: ServiceError!
        switch UserAPITests.testUserResponse {
        case .failure(let error):
            serviceErrorExpect = error
        case .success(_ ): break
        case .none: break
        }

        // Then
        XCTAssertEqual(serviceErrorExpect, serviceErrorResult, "Test error is the same type")
    }
}
