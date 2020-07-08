//
//  RequestToken.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 08/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation
class RequestToken {
    private weak var task: URLSessionDataTask?
    init(task: URLSessionDataTask?) {
        self.task = task

    }
    func cancel() {
        task?.cancel()

    }
}
