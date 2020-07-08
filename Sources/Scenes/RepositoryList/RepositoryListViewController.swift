//
//  RepositoryListViewController.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright (c) 2020 Mauricio Balena Mazzocco. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import Kingfisher

protocol RepositoryListDisplayLogic: class {
    func displayRepositories(viewModel: RepositoryList.FetchRepositories.ViewModel)
    func displayLoading()
    func displayError(viewModel: RepositoryList.Error.ViewModel)
}

class RepositoryListViewController: UIViewController, RepositoryListDisplayLogic {

    var interactor: RepositoryListBusinessLogic?
    var router: (NSObjectProtocol & RepositoryListRoutingLogic & RepositoryListDataPassing)?

    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup

    private func setup() {
        let viewController = self
        let interactor = RepositoryListInteractor()
        let presenter = RepositoryListPresenter()
        let router = RepositoryListRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }

    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    // MARK: View lifecycle

    internal lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = 100
        table.showsVerticalScrollIndicator = false
        table.estimatedRowHeight = 100
        table.backgroundColor = .white
        table.delegate = self
        table.prefetchDataSource = self
        table.dataSource = self
        table.refreshControl = refreshControl
        table.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.reuseId)
        table.tableFooterView = nextPageProgressIndicator
        return table
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = R.color.gitBlue()
        return refreshControl
    }()

    private lazy var nextPageProgressIndicator: UIActivityIndicatorView = {
        let progress = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        progress.color = R.color.gitBlue()
        progress.hidesWhenStopped = true
        progress.frame = .init(x: 0, y: 0, width: 44, height: 44)
        return progress
    }()

    private lazy var loadingView: UIActivityIndicatorView = {
        let progress = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        progress.color = R.color.gitBlue()
        progress.hidesWhenStopped = true
        progress.frame = .init(x: 0, y: 0, width: 44, height: 44)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    internal  var displayedRepositories: [RepositoryList.FetchRepositories.ViewModel.DisplayedRepository] = []
    private var hasMoreItems = false
    private var state: State = .idle
    private var showingAlert = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("repositories", comment: "")
        updateColors()
        fetchRepositories()
    }

    private func updateColors() {
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = R.color.gitBlue()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConstraints()
    }

    private func setupConstraints() {
        view.addSubview(tableView)
        view.addSubview(loadingView)

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupElements() {
        nextPageProgressIndicator.isHidden = true
    }

    @objc
    private func refresh() {
        self.fetchRepositories(isReloading: true)
    }

    private func reloadItems(
        repositories: [RepositoryList.FetchRepositories.ViewModel.DisplayedRepository]) {

        let indexes = repositories.enumerated()
            .reduce([IndexPath](), { (acc, t) in
                return acc + [IndexPath(row: t.offset + self.displayedRepositories.count, section: 0)]
            })
        let displayedRepositoriesCount = displayedRepositories.count
        displayedRepositories.append(contentsOf: repositories)

        if displayedRepositoriesCount < 30 {
            tableView.reloadData()
            self.state = .loadedPage
        } else {
            self.tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexes, with: .none)
                },
                completion: { _ in
                self.state = .loadedPage
                }
            )
        }
    }
}

// MARK: Requests

extension RepositoryListViewController {
    func fetchRepositories(isReloading: Bool = false) {
        state = .loadingPage
        let request = RepositoryList.FetchRepositories.Request(isReloading: isReloading)
        interactor?.fetchRepositories(request: request)
    }
}

// MARK: Displays

extension RepositoryListViewController {
    func displayRepositories(viewModel: RepositoryList.FetchRepositories.ViewModel) {
        hasMoreItems = viewModel.hasNext
        loadingView.isHidden = true
        nextPageProgressIndicator.isHidden = !viewModel.hasNext

        if viewModel.hasNext {
            nextPageProgressIndicator.startAnimating()
        }
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }

        if viewModel.isReloading {
            displayedRepositories = []
            self.tableView.reloadData()
        }
        self.reloadItems(repositories: viewModel.displayedRepositories)
    }

    func displayLoading() {
        loadingView.startAnimating()
    }

    func displayError(viewModel: RepositoryList.Error.ViewModel) {

        state = .loadedPage
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
        nextPageProgressIndicator.isHidden = true

        if !showingAlert {
            let alert = UIAlertController(
                title: NSLocalizedString("errorTitle", comment: ""),
                message: viewModel.errorString,
                preferredStyle: UIAlertController.Style.alert
            )

            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("ok", comment: ""),
                    style: UIAlertAction.Style.default,
                    handler: { [weak self] _ in
                        self?.showingAlert = false
                    }
                )
            )
            alert.addAction(
                UIAlertAction(
                    title: NSLocalizedString("tryAgain", comment: ""),
                    style: UIAlertAction.Style.default,
                    handler: { [weak self] _ in
                        guard let self = self else { return }
                        self.showingAlert = false
                        self.nextPageProgressIndicator.isHidden = false
                        self.fetchRepositories()
                    }
                )
            )

            self.present(alert, animated: true, completion: nil)
        }

        showingAlert = true
    }
}

extension RepositoryListViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {

        indexPaths
            .map { displayedRepositories[$0.row] }
            .forEach { model in
                if let path = model.userAvatarPath, let url = URL(string: path) {
                    ImagePrefetcher(urls: [url]).start()
                }
            }
    }
}

extension RepositoryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedRepositories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseId, for: indexPath)
        if let cellRepository = cell as? RepositoryCell {
            cellRepository.model = displayedRepositories[indexPath.row]
            return cellRepository

        }
        return  UITableViewCell()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
extension RepositoryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if  hasMoreItems && indexPath.row >= displayedRepositories.count - 15 && state == .loadedPage {
            self.fetchRepositories()
        }
    }
}
