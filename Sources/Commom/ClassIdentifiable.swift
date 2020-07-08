//
//  ClassIdentifiable.swift
//  GitCleanSwift
//
//  Created by Mauricio Balena Mazzocco on 04/07/20.
//  Copyright © 2020 Mauricio Balena Mazzocco. All rights reserved.
//

import UIKit

protocol ClassIdentifiable: class {
    static var reuseId: String { get }
}

extension ClassIdentifiable {
    static var reuseId: String {
        return String(describing: self)
    }
}
