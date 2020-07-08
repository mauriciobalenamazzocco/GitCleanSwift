//
//  ApiCollectionResponseCodable.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 05/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import Foundation
public struct ApiCollectionResponseCodable<T: Codable>: Codable {
    public var items: [T]
}
