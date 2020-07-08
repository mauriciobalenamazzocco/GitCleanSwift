//
//  UserAPI.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

class UserAPI: UserStoreProtocol {

    let urlSession: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchUser(url: String, completionHandler: @escaping (UserResponse) -> Void) {

        guard let url = URL(string: url) else {
            completionHandler(.failure(.urlInvalid))
            return 
        }

        let dataTask = urlSession.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completionHandler(.failure(.api(error)))
            } else if let data = data {
                guard let userResponse = try? JSONDecoder().decode(User.self, from: data) else {
                    completionHandler(.failure(.parse))
                    return
                }
                completionHandler(.success(userResponse))
            }
        }
        dataTask.resume()
    }
}
