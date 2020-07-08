//
//  UserTests.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 05/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation
@testable import GitCleanSwift
import XCTest

class UserTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func getJsonMock() -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let filePath = testBundle.path(forResource: "UserJsonMock", ofType: "txt")
        else { fatalError() }
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return jsonData
    }

    func test_Fields_Correct() {
        guard let user = try? JSONDecoder().decode(User.self, from: getJsonMock()) else {
            return XCTFail()
        }
        
        XCTAssertEqual(user.avatarUrl, "https://avatars2.githubusercontent.com/u/484656?v=4")
        XCTAssertEqual(user.login, "vsouza")
        XCTAssertEqual(user.name, "Vinicius Souza")

    }

    func test_Equals_User() {
        let user1 = User(name: "name", avatarUrl: "avatarUrl", login: "login")
        let user2 = User(name: "name", avatarUrl: "avatarUrl", login: "login")

        XCTAssertEqual(user1, user2)
    }
}
