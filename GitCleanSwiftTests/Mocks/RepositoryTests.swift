//
//  RepositoryTests.swift
//  RepoSearcher
//
//  Created by Arthur Myronenko on 7/13/17.
//  Copyright © 2017 UPTech Team. All rights reserved.
//

@testable import GitRxSwift
import XCTest

class RepositoryTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func getJsonMock() -> Data {
        let testBundle = Bundle(for: type(of: self))
        guard let filePath = testBundle.path(forResource: "RepositoryJsonMock", ofType: "txt")
        else { fatalError() }
        let jsonData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return jsonData
    }

    func test_Correct_List_Count() {
        guard let colectionResponse = try? JSONDecoder().decode(ApiCollectionResponseCodable<Repository>.self, from: getJsonMock()) else {

            return XCTFail()
        }

        XCTAssertEqual(colectionResponse.items.count, 30)
    }

    func test_First_Fields_Correct() {
        guard let colectionResponse = try? JSONDecoder().decode(ApiCollectionResponseCodable<Repository>.self, from: getJsonMock()) else {
            return XCTFail()
        }

        let repository = colectionResponse.items.first

        XCTAssertEqual(repository?.name, "awesome-ios")
        XCTAssertEqual(repository?.starsCount, 35185)
        XCTAssertEqual(repository?.owner?.avatarUrl, "https://avatars2.githubusercontent.com/u/484656?v=4")
        XCTAssertEqual(repository?.owner?.url, "https://api.github.com/users/vsouza")
    }

    func test_Equals_Repository() {
        let repo1 = Repository(name: name, starsCount: 0, owner: Owner(url: "url", avatarUrl: "avatarUrl"))
        let repo2 = Repository(name: name, starsCount: 0, owner: Owner(url: "url", avatarUrl: "avatarUrl"))

        XCTAssertEqual(repo1, repo2)
    }
}
