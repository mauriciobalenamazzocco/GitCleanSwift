//
//  UserAPI.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

class UserAPI: UserStoreProtocol {

    let urlSession: URLSessionProtocol

    init(urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlSession = urlSession
    }

    func fetchUser(url: String, completionHandler: @escaping (UserResponse) -> Void) -> RequestToken {

        guard let url = URL(string: url) else {
            completionHandler(.failure(.urlInvalid))
            return  RequestToken(task: nil)
        }

        let dataTask = urlSession.dataTask(with: URLRequest(url: url)) { (data, _, error) in
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
         return RequestToken(task: dataTask)
    }
}
