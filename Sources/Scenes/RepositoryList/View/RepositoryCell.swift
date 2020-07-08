//
//  RepositoryCell.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

// swiftlint:disable empty_enum_arguments
class RepositoryCell: UITableViewCell, ClassIdentifiable {

    internal lazy var avatarImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.layer.cornerRadius = 35
        img.clipsToBounds = true
        return img
    }()

    internal lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    internal lazy var repositoryNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor =  .white
        label.backgroundColor = R.color.gitBlue()
        label.layer.cornerRadius = 5
        label.clipsToBounds = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var starsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [repositoryNameLabel, starsLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var vStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel, hStackView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    var model: RepositoryList.FetchRepositories.ViewModel.DisplayedRepository? {
        didSet {
            guard let model = model else { return }
            updateCell(with: model)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(vStackView)
        backgroundColor  = .white
        selectionStyle = .none
        avatarImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        avatarImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor,
                                                 constant: 10).isActive = true

        avatarImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true

        vStackView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true

        vStackView.leadingAnchor.constraint(
            equalTo: self.avatarImageView.trailingAnchor,
            constant: 10).isActive = true

        self.contentView.trailingAnchor.constraint(
            equalTo: self.vStackView.trailingAnchor,
            constant: 10
        ).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        starsLabel.text = ""
        repositoryNameLabel.text = ""
        userNameLabel.text = ""
    }

    // MARK: - Update Cell Functions
    var userApi: UserStoreProtocol!

    private func updateCell(
        with model: RepositoryList.FetchRepositories.ViewModel.DisplayedRepository,
        userAPI: UserStoreProtocol = UserAPI()) {
        userApi = userAPI
        starsLabel.text = model.repoStarsCount
        repositoryNameLabel.text = model.repoName
        updateImage(avatarPath: model.userAvatarPath)
        updateUser(userUrl: model.userProfilePath)
    }

    private func updateImage(avatarPath: String?) {
         guard let path = avatarPath,
            let url = URL(string: path)
            else { return }

        avatarImageView.kf.setImage(
            with: url,
            placeholder: R.image.userPlaceholder(),
            options: []
        )
    }

    private func updateUser(userUrl: String?) {
        guard let url = userUrl else { return }
        userApi.fetchUser(url: url) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.userNameLabel.text = user?.name
                case .failure( _): break
                }
            }
        }
    }
}
