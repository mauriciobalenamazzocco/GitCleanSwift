//
//  RepositoryApi.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 06/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation

class RepositoryAPI: RepositoryStoreProtocol {

    let urlSession: URLSession

     init(urlSession: URLSession = URLSession.shared) {
       self.urlSession = urlSession
     }

    func fetchRepositories(
        url: String,
        completionHandler: @escaping (RespositoriesResponse) -> Void ) {

        guard let url = URL(string: url) else {
            completionHandler(.failure(.urlInvalid))
            return
        }

        let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(.api(error)))
            } else if let data = data {
                guard let colectionResponse = try? JSONDecoder().decode(ApiCollectionResponseCodable<Repository>.self, from: data) else {
                    completionHandler(.failure(.parse)) // Status Code: 403 - API limit
                    return
                }
                guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse else {
                    completionHandler(.failure(.parse))
                    return
                }
                let nextUrl = httpResponse.allHeaderFields["Link"] as? String
                let list = nextUrl?.extractUrl()
                let listPage = ListPage(items: colectionResponse.items, page: list ?? "", hasNext: list != nil)
                completionHandler(.success(listPage))
            }
        }
          dataTask.resume()
    }
}

extension RepositoryAPI {
    static let apiRepositoryPath = "https://api.github.com/search/repositories?q=language%3Aswift&sort=stars"
}
