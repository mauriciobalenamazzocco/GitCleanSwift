//
//  RepositoryListViewControllerTests.swift
//  GitCleanSwiftTests
//
//  Created by Mauricio Balena Mazzocco on 07/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//


@testable import GitCleanSwift
import XCTest

class RepositoryListViewControllerTests: XCTestCase
{
    // MARK: - Subject under test

    var repositoryListViewController: RepositoryListViewController!
    var window: UIWindow!

    // MARK: - Test lifecycle
    override func setUp()
    {
        super.setUp()
        window = UIWindow()
        setupRepositoryListViewController()
   
    }

    override func tearDown()
    {
        window = nil
        super.tearDown()
    }

    // MARK: - Test setup

    func setupRepositoryListViewController()
    {
        repositoryListViewController = RepositoryListViewController()
    }

    func loadView()
    {
        window.addSubview(repositoryListViewController.view)
        RunLoop.current.run(until: Date())
    }

    // MARK: - Test doubles

    class RepositoryListBusinessLogicSpy: RepositoryListBusinessLogic
    {

        // MARK: Method call expectations

        var fetchRepositoriesCall = false

        // MARK: Spied methods

        func fetchRepositories(request: RepositoryList.FetchRepositories.Request) {
            fetchRepositoriesCall = true
        }
    }

    class TableViewSpy: UITableView
    {
        // MARK: Method call expectations

        var reloadDataCalled = false

        // MARK: Spied methods

        override func reloadData()
        {
            reloadDataCalled = true
        }
    }

    // MARK: - Tests

    func test_FetchedRepositoriesDidAppear()
    {
        // Given
        let repositoryListBusinessLogicSpy = RepositoryListBusinessLogicSpy()
        repositoryListViewController.interactor = repositoryListBusinessLogicSpy
        loadView()

        // When
        repositoryListViewController.viewDidAppear(true)

        // Then
        XCTAssert(repositoryListBusinessLogicSpy.fetchRepositoriesCall)
    }


    func test_FetchedRepositoriesStateIddle()
    {


        XCTAssertEqual(repositoryListViewController.state, .idle)
        

    }

    func test_FetchedRepositoriesDidAppearState()
    {
        // Given
        loadView()

        // When
        repositoryListViewController.viewDidAppear(true)

        // Then
          XCTAssertEqual(repositoryListViewController.state, .loadingPage)
    }

    func test_FetchedRepositoriesDisplay()
    {
        let displayRepository = RepositoryList.FetchRepositories.ViewModel.DisplayedRepository(repoName: "repoName", userAvatarPath: "avatarName", repoStarsCount: "repoStarCount", userProfilePath: "userProfilePath")
        let displayedRepositories = [displayRepository]
        let viewModel = RepositoryList.FetchRepositories.ViewModel(displayedRepositories: displayedRepositories, isReloading: false, hasNext: false)
        repositoryListViewController.displayRepositories(viewModel: viewModel)

        // Then
        XCTAssertEqual(repositoryListViewController.state, .loadedPage)
    }


    func test_ErrorDisplay()
    {

        let viewModel = RepositoryList.Error.ViewModel(errorString: "error")
        repositoryListViewController.displayError(viewModel: viewModel)

        // Then
        XCTAssert(repositoryListViewController.showingAlert)
    }


    func test_FetchedRepositoriesStateLoaded()
    {
        // Given
        let tableViewSpy = TableViewSpy()
        repositoryListViewController.tableView = tableViewSpy

        // When
        let displayRepository = RepositoryList.FetchRepositories.ViewModel.DisplayedRepository(repoName: "repoName", userAvatarPath: "avatarName", repoStarsCount: "repoStarCount", userProfilePath: "userProfilePath")
        let displayedRepositories = [displayRepository]
        let viewModel = RepositoryList.FetchRepositories.ViewModel(displayedRepositories: displayedRepositories, isReloading: false, hasNext: false)
        repositoryListViewController.displayRepositories(viewModel: viewModel)

        // Then
        XCTAssert(tableViewSpy.reloadDataCalled, "Reloaded table view after display")
    }

      func test_NumberOfSections()
      {
        // Given
        let tableView = repositoryListViewController.tableView

        // When
        let numberOfSections = repositoryListViewController.numberOfSections(in: tableView)

        // Then
        XCTAssertEqual(numberOfSections, 1, "The number of table view sections should always be 1")
      }

      func test_NumberOfRows()
      {
        // Given
        let tableView = repositoryListViewController.tableView
        let displayRepository = RepositoryList.FetchRepositories.ViewModel.DisplayedRepository(repoName: "repoName", userAvatarPath: "avatarName", repoStarsCount: "repoStarCount", userProfilePath: "userProfilePath")
        let testDisplayedRepositories = [displayRepository]

        repositoryListViewController.displayedRepositories = testDisplayedRepositories

        // When
        let numberOfRows = repositoryListViewController.tableView(tableView, numberOfRowsInSection: 0)

        // Then
        XCTAssertEqual(numberOfRows, testDisplayedRepositories.count)
      }

    func test_CellForRow()
    {
        // Given
        let tableView = repositoryListViewController.tableView
        let displayRepository = RepositoryList.FetchRepositories.ViewModel.DisplayedRepository(repoName: "repoName", userAvatarPath: "avatarName", repoStarsCount: "repoStarCount", userProfilePath: "userProfilePath")
        let testDisplayedRepositories = [displayRepository]
        repositoryListViewController.displayedRepositories = testDisplayedRepositories

        // When
        let indexPath = IndexPath(row: 0, section: 0)

        // Then
        if let cell = repositoryListViewController.tableView(tableView, cellForRowAt: indexPath) as? RepositoryCell {
            XCTAssertEqual(cell.repositoryNameLabel.text, "repoName")
            XCTAssertEqual(cell.starsLabel.text, "repoStarCount")
            return
        }

        XCTFail()
    }
}
